# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/AD/DC.psm1
using module ./Modules/Core/NetworkAdapter.psm1

# Install the Active Directory Domain Services role
$ADDS = [ADDS]::new()

# Path to the JSON file
$PathToGenerateJSON = $RootPath + "\Resources\Config\"
$PathToGenerateJSON += Read-Host -Prompt "Enter the name to the JSON file"

# Read the JSON file
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json


# Network adapter info from the JSON file
$NetworkAdapterInfo = $ADConfig.Forest.DomainController.NetAdapter


[IPAddress[]]$DNSServers += $NetworkAdapterInfo.DNSServer

# Change the network adapter configuration
[NetworkAdapter[]]$Adapters += [NetworkAdapter]::new($NetworkAdapterInfo.Name, $NetworkAdapterInfo.IPAddress, $NetworkAdapterInfo.PrefixLength, $NetworkAdapterInfo.DefaultGateway, $DNSServers)

# Create the new domain controller
$DC = [DC]::new($ADConfig.Forest.DomainController.Name, $ADConfig.Forest.DomainController.Site, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainController.OSVersion, $ADConfig.Forest.DomainController.InstallDNS, $Adapters)

# Create the new forest
$ADDS.CreateForest($ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainMode, $ADConfig.Forest.ForestMode, $ADConfig.Forest.SafeModeAdministratorPassword)

