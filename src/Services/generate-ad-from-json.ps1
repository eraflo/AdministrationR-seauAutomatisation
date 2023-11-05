# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1


# Import JSON file with the configuration for AD
$JSONADConfig = "$RootPath\Resources\Config\config-ad.json"
$JSONADConfig = Get-Content -Path $JSONADConfig | ConvertFrom-Json

Write-Host $JSONADConfig

$ADDS = [ADDS]::new()
Write-Host $ADDS.Name