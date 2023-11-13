using module ../../Modules/AD/OU.psm1

# Ask the name of the OU to deplace
$Name = Read-Host -Prompt "Enter the name of the OU to deplace"

# Check if OU exist
$OU = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'"

if($OU -eq $null) {
    Write-HostAndLog -Message "The OU $Name does not exist"
    exit
}

if($OU.Count -gt 1) {
    Write-HostAndLog -Message "There are more than one OU with the name $Name"
    exit
}

# Ask the new Path
$NewPath = Read-Host -Prompt "Enter the new path of the OU (format: OU=,DC=,DC=)"

# Check if correct
if($NewPath -notmatch "OU=") {
    Write-HostAndLog -Message "The path must start with OU=" 
    exit
}

# Deplace the OU
$OU = [OU]::new($OU.DistinguishedName, $OU.Name, $OU.ProtectedFromAccidentalDeletion)

$OU.Deplace($NewPath)
