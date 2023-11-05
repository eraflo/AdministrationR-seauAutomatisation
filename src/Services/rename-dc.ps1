using module ./Modules/AD/DC.psm1
using module ./Modules/Core/NetworkAdapter.psm1

# Path to the JSON file
$PathToGenerateJSON = $RootPath + "\Resources\Config\"
$PathToGenerateJSON += Read-Host -Prompt "Enter the name to the JSON file"

# Read the JSON file
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json

$NewName = Write-Host -Prompt "Enter the new name for the domain controller"

# Update the JSON file
$ADConfig.Forest.DomainController.Name = $NewName
$ADConfig | ConvertTo-Json | Set-Content -Path $PathToGenerateJSON

# Create a new domain controller object
$DC = [DC]::new($ADConfig.Forest.DomainController.Name, $ADConfig.Forest.DomainController.Site, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainController.OSVersion, $ADConfig.Forest.DomainController.InstallDNS, $Adapters)

# Rename the domain controller
$DC.Rename()