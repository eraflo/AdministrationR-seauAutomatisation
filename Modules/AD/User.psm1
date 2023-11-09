# class representing an AD user

class User {
    [string]$FirstName
    [string]$Lastname
    [string]$SamAccountName
    [string]$DistinguishedName
    [SecureString] $AccountPassword = (ConvertTo-SecureString -AsPlainText "P@ssw0rd" -Force)
    [string]$EmailAddress
    [string]$Fonction
    [string]$UserPrincipalName

    
    # constructor
    # Default
    User() {
        throw "You must specify parameters"
    }

    User([string]$FirstName, [string]$Lastname,  [string]$Fonction, [string]$DC1, [string]$DC2) {
        $this.FirstName = $FirstName
        $this.Lastname = $Lastname
        $this.SamAccountName = $FirstName.Substring(0,1).ToLower() + $Lastname.ToLower()
        $this.DistinguishedName = "CN=$FirstName $Lastname,OU=Users, DC=$DC1, DC=$DC2"
        $this.EmailAddress = "$($this.SamAccountName)@$($DC1).fr"
        $this.Fonction = $Fonction
        $this.UserPrincipalName = "$($this.SamAccountName)@$($DC1).$($DC2)"
    }

    # Create the user in the domain
    [void]Create() {
        # Check if the user already exists
        if (Get-ADUser -Filter {SamAccountName -eq $this.SamAccountName}) {
            throw "User $($this.SamAccountName) already exists"
        }

        # Create the user
        try {
            @{
                Name = "$($this.FirstName) $($this.Lastname)"
                DisplayName = "$($this.FirstName) $($this.Lastname)"
                GivenName = $this.FirstName
                Surname = $this.Lastname
                SamAccountName = $this.SamAccountName
                UserPrincipalName = $this.UserPrincipalName
                EmailAddress = $this.EmailAddress
                Title = $this.Fonction
                Path = "OU=Users, DC=$($this.DC1), DC=$($this.DC2)"
                ChangePasswordAtLogon = $true
                Enabled = $false
                AccountPassword = $this.AccountPassword
            } | New-ADUser
            Write-HostAndLog "User $($this.SamAccountName) created"
        }
        catch {
            throw "Error creating user $($this.SamAccountName)"
        }
    }
}

