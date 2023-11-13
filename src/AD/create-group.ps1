using module ../../Modules/AD/Group.psm1

# Ask for group name
$Name = Read-Host -Prompt "Enter the name of the group"

# Ask for the path
$Path = Read-Host -Prompt "Enter the path of the group (format: OU=,DC=,DC=)"

# Check if path is correct
if($Path -notmatch "OU=") {
    Write-HostAndLog -Message "The path must start with OU=" 
    exit
}

# Ask for group scope
$Scope = Read-Host -Prompt "Enter the scope of the group (DomainLocal, Global, Universal)"

# Check if scope is correct
if($Scope -ne "DomainLocal" -and $Scope -ne "Global" -and $Scope -ne "Universal") {
    Write-HostAndLog -Message "The scope must be DomainLocal, Global or Universal"
    exit
}

# Ask for group type
$Type = Read-Host -Prompt "Enter the type of the group (Distribution, Security)"

# Check if type is correct
if($Type -ne "Distribution" -and $Type -ne "Security") {
    Write-HostAndLog -Message "The type must be Distribution or Security"
    exit
}

# Ask for group description
$Description = Read-Host -Prompt "Enter the description of the group"

$Members = [string []]

# Ask for number of members
$Number = Read-Host -Prompt "Enter the number of members"

# Ask for members
for($i = 0; $i -lt $Number; $i++) {
    $member = Read-Host -Prompt "Enter the name of the member (format: CN=,OU=,DC=,DC=)"

    # Check if exists
    $member = Get-ADObject -Filter "Name -eq '$member'"

    if($member -eq $null) {
        Write-HostAndLog -Message "The member $member does not exist"
        exit
    }

    $Members += $member.DistinguishedName
}

# Create the group
$Group = [Group]::new($Path, $Name, $Scope, $Type, $Description, $Members)

# Add the group
$Group.Create()