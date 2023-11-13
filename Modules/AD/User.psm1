# class representing an AD user

class User {
    [string]$FirstName
    [string]$Lastname
    [string]$SamAccountName
    [string]$DistinguishedName
    [string]$EmailAddress
    [string]$Fonction
    [string]$UserPrincipalName
    [string]$DC1
    [string]$DC2

    
    # constructor
    # Default
    User() {
        throw "You must specify parameters"
    }

    User([string]$FirstName, [string]$Lastname,  [string]$Fonction, [string]$DC1, [string]$DC2) {
        #  Check if domain exists
        if (-not (Get-ADDomain -Server ($DC1 + "." + $DC2))) {
            throw "The domain $DC1.$DC2 does not exist"
        }
        
        $this.FirstName = $FirstName
        $this.Lastname = $Lastname
        if(($this.FirstName + $this.Lastname).Length -gt 20) {
            $this.SamAccountName = ($this.FirstName + $this.Lastname).Substring(0, 20)
        }
        else {
            $this.SamAccountName = ($this.FirstName + $this.Lastname)
        }
        $this.DistinguishedName = "CN=$FirstName $Lastname,OU=Users, DC=$DC1, DC=$DC2"
        $this.EmailAddress = "$($this.SamAccountName)@$($DC1).fr"
        $this.Fonction = $Fonction
        $this.UserPrincipalName = "$($this.SamAccountName)@$($DC1).fr"
        $this.DC1 = $DC1
        $this.DC2 = $DC2
    }

    # Create the user in the domain
    [void]Create() {
        # Check if the user already exists
        if (Get-ADUser -Filter {SamAccountName -eq $this.SamAccountName}) {
            throw "User $($this.SamAccountName) already exists"
        }

        # Create the user
        try {
            $Attributs = @{
                Name = "$($this.FirstName) $($this.Lastname)"
                SamAccountName = $this.SamAccountName
                GivenName = $this.FirstName
                Surname = $this.Lastname
                DisplayName = "$($this.FirstName) $($this.Lastname)"
                UserPrincipalName = $this.UserPrincipalName
                EmailAddress = $this.EmailAddress
                Path = "CN=Users, DC=$($this.DC1), DC=$($this.DC2)"
                AccountPassword = (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force)
                Enabled = $false
                ChangePasswordAtLogon = $true
            } 

            New-ADUser @Attributs
            Write-HostAndLog "User $($this.SamAccountName) created"
        }
        catch {
            Write-HostAndLog $_.Exception.Message
            throw "Error creating user $($this.SamAccountName)"
        }
    }
}

