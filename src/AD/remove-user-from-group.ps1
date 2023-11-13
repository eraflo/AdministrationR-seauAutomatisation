using module ../../Modules/AD/Group.psm1

# Ask user samAccountName
$SamAccountName = Read-Host -Prompt "Enter the samAccountName of the user"

# Check if user exists
$User = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'"

if($User -eq $null) {
    Write-HostAndLog -Message "The user $SamAccountName does not exist"
    exit
}

# Ask group name
$Name = Read-Host -Prompt "Enter the name of the group"

# Check if group exists
$Group = Get-ADGroup -Filter "Name -eq '$Name'"

if($Group -eq $null) {
    Write-HostAndLog -Message "The group $Name does not exist"
    exit
}

if($Group.Count -gt 1) {
    Write-HostAndLog -Message "There are more than one group with the name $Name"
    exit
}

# Add the user in the group
$Group = [Group]::new($Group.DistinguishedName, $Group.Name, $Group.GroupScope, $Group.GroupCategory, $Group.Description, $Group.Members)

$Group.RemoveMember($SamAccountName)

