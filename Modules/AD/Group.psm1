# Class for group

class Group {
    # Path to the group
    [string]$Path

    # Name of the group
    [string]$Name

    # Group scope
    [string]$Scope

    # Group type
    [string]$Type

    # Group description
    [string]$Description

    # Group members
    [string[]]$Members

    Group ([string]$Path, [string]$Name, [string]$Scope, [string]$Type, [string]$Description, [string[]]$Members) {
        $this.Path = $Path
        $this.Name = $Name
        $this.Scope = $Scope
        $this.Type = $Type
        $this.Description = $Description
        $this.Members = $Members
    }

    # Create the group
    [void]Create() {
        Write-HostAndLog -Message "Creating the group $($this.Name)" 
        
        try {
            $info = @{
                Path = $this.Path
                Name = $this.Name
                GroupScope = $this.Scope
                GroupCategory = $this.Type
                Description = $this.Description
            }

            # Creat the group
            New-ADGroup @info -ErrorAction Stop

            # Sucess message
            Write-HostAndLog -Message "The group $($this.Name) has been created successfully"
        }
        catch  {
            # Error message
            Write-HostAndLog -Message "The group $($this.Name) has not been created successfully"
            Write-HostAndLog -Message "Check the path and the name of the group"
            Write-HostAndLog -Message $_.Exception.Message 
            exit
        }

    }

    # Add members to the group
    [void]AddMember([string]$MembersName) {
        Write-HostAndLog -Message "Adding members to the group $($this.Name)" 

        try {
            # Get the user
            $user = Get-ADUser -Filter "SamAccountName -eq '$MembersName'"

            Write-Host $user

            $info = @{
                Identity = $this.Path
                Members = $user.DistinguishedName
            }

            # Add members to the group
            Add-ADGroupMember @info -ErrorAction Stop

            # Sucess message
            Write-HostAndLog -Message "The members have been added to the group $($this.Name) successfully"
        }
        catch  {
            # Error message
            Write-HostAndLog -Message "The members have not been added to the group $($this.Name) successfully"
            Write-HostAndLog -Message "Check the path and the members of the group"
            Write-HostAndLog -Message $_.Exception.Message
            exit
        }
    }

    # Remove members from the group
    [void]RemoveMember([string]$MembersName) {
        Write-HostAndLog -Message "Removing members from the group $($this.Name)" 

        try {
            # Get the user
            $user = Get-ADUser -Filter "SamAccountName -eq '$MembersName'"

            $info = @{
                Identity = $this.Path
                Members = $user.DistinguishedName
            }

            # Remove members from the group
            Remove-ADGroupMember @info -ErrorAction Stop

            # Sucess message
            Write-HostAndLog -Message "The members have been removed from the group $($this.Name) successfully"
        }
        catch  {
            # Error message
            Write-HostAndLog -Message "The members have not been removed from the group $($this.Name) successfully"
            Write-HostAndLog -Message "Check the path and the members of the group"
            Write-HostAndLog -Message $_.Exception.Message
            exit
        }
    }
}