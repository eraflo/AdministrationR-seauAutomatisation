# Class for OU

class OU {

    # Path to the OU
    [string]$Path

    # Name of the OU
    [string]$Name

    #Protected OU or not
    [bool]$Protected

    OU ([string]$Path, [string]$Name, [bool]$Protected) {
        $this.Path = $Path
        $this.Name = $Name
        $this.Protected = $Protected
    }

    # Create the OU
    [void]Create([bool]$AtRoot) {
        Write-HostAndLog -Message "Creating the OU $($this.Name)" 

        
        try {
            $info = @{
                Path = $this.Path
                Name = $this.Name
                ProtectedFromAccidentalDeletion = $this.Protected
            }

            # Creat the OU
            New-ADOrganizationalUnit @info -ErrorAction Stop

            # Sucess message
            Write-HostAndLog -Message "The OU $($this.Name) has been created successfully"
        }
        catch  {
            # Error message
            Write-HostAndLog -Message "The OU $($this.Name) has not been created successfully"
            Write-HostAndLog -Message "Check the path and the name of the OU"
            Write-HostAndLog -Message $_.Exception.Message 
            exit
        }

    }

    # Deplace OU 
    [void]Deplace([string]$NewPath) {
        # Removing the protection
        try {
            Set-ADOrganizationalUnit -Identity $this.Path -ProtectedFromAccidentalDeletion $false
        }
        catch {
            Write-HostAndLog -Message "The OU $($this.Name) has not been deplaced successfully"
            Write-HostAndLog -Message $_.Exception.Message 
            exit
        }

        # Deplace the OU
        try {
            Write-HostAndLog -Message "Deplacing the OU $($this.Name) to $NewPath"
            Move-ADObject -Identity $this.Path -TargetPath $NewPath -ErrorAction Stop
            $this.Path = $NewPath
        }
        catch {
            Write-HostAndLog -Message "The OU $($this.Name) has not been deplaced successfully"
            Write-HostAndLog -Message $_.Exception.Message 
            exit
        }

        if($this.Protected) {
            try {
                Set-ADOrganizationalUnit -Identity $this.Path -ProtectedFromAccidentalDeletion $true
            }
            catch {
                Write-HostAndLog -Message "The OU $($this.Name) has had a problem setting it to protected"
                Write-HostAndLog -Message $_.Exception.Message 
                exit
            }
        }

    }
    

}