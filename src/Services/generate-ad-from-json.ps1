# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/GenerateConfig/GenerateAdConfig.psm1



# Import JSON file with the configuration for AD
$JSONADConfig = "$RootPath\Resources\Config\config-ad.json"
$JSONADConfig = Get-Content -Path $JSONADConfig | ConvertFrom-Json

Write-Host $JSONADConfig

GenerateADConfigFile($RootPath)