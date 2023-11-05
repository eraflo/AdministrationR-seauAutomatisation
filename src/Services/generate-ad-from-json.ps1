# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/GenerateConfigs.psm1

GenerateADConfigFile($RootPath)

# Wait for the user to fill the JSON file
Write-Host "Please fill the JSON file at : $PathToGenerateJSON"
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Read the JSON file
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json

# Install the Active Directory Domain Services role
[ADDS]::new()

# Create the new forest
[ADDS]::CreateForest($ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainMode, $ADConfig.Forest.ForestMode, $ADConfig.Forest.SafeModeAdministratorPassword)