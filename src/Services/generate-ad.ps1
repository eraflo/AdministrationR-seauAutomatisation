# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/GenerateConfigs.psm1

# Install the Active Directory Domain Services role
$ADDS = [ADDS]::new()


# Generate the JSON file for the AD configuration
$PathToGenerateJSON = GenerateADConfigFile($RootPath)

# Wait for the user to fill the JSON file
Write-Host "Please see if the JSON file is filled correctly at : $PathToGenerateJSON"
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Read the JSON file
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json

# Create the new forest
$ADDS.CreateForest($ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainMode, $ADConfig.Forest.ForestMode, $ADConfig.Forest.SafeModeAdministratorPassword)

# Promote the server as a domain controller
foreach($DC in $ADConfig.Forest.DomainControllers) {
    $ADDS.Promote($DC.Name, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.SafeModeAdministratorPassword, $DC.Site, $DC.ReplicationSourceDC, $DC.InstallDNS, $ADConfig.Forest.DomainMode, $ADConfig.Forest.ForestMode)
}
