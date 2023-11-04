# Generation of Active Directory objects from JSON file


# Import JSON file with the configuration for AD
$JSONADConfig = "$RootPath\Resources\Config\config-ad.json"
$JSONADConfig = Get-Content -Path $JSONADConfig | ConvertFrom-Json

Write-Host $JSONADConfig
