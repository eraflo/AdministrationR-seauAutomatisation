# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/GenerateConfigs.psm1
using module ./Modules/Core/NetworkAdapter.psm1

# Install the Active Directory Domain Services role
$ADDS = [ADDS]::new()


# Generate the JSON file for the AD configuration
$choice = Read-Host -Prompt "Do you want to generate a JSON file for the AD configuration ? (y/n)"
if($choice -eq "y") {
    $PathToGenerateJSON = GenerateADConfigFile($RootPath)
}
else {
    $PathToGenerateJSON = $RootPath + "\Resources\Config\"
    $PathToGenerateJSON += Read-Host -Prompt "Enter the name to the JSON file"
}

# Wait for the user to fill the JSON file
Write-Host "Please see if the JSON file is filled correctly at : $PathToGenerateJSON"
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Read the JSON file
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json


# Network adapter info from the JSON file
$NetworkAdapterInfo = $ADConfig.Forest.DomainController.NetworkAdapter


[IPAddress[]]$DNSServers += $NetworkAdapterInfo.DNSServer

# Change the network adapter configuration
[NetworkAdapter]::new($NetworkAdapterInfo.Name, $NetworkAdapterInfo.IPAddress, $NetworkAdapterInfo.PrefixLength, $NetworkAdapterInfo.DefaultGateway, $DNSServers)

# Create the new forest
$ADDS.CreateForest($ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainMode, $ADConfig.Forest.ForestMode, $ADConfig.Forest.SafeModeAdministratorPassword)

