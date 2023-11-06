using module ./Modules/AD/DC.psm1
using module ./Modules/Core/NetworkAdapter.psm1

# Path to the JSON file
$PathToGenerateJSON = $RootPath + "\Resources\Config\"

do {
    $PathToGenerateJSON += Read-Host -Prompt "Enter the name to the JSON file"

    # Add the extension if it is not present
    if (-not $PathToGenerateJSON.EndsWith(".json")) {
        $PathToGenerateJSON += ".json"
    }

    # Check if the file exists
    if (-not (Test-Path -Path $PathToGenerateJSON)) {
        Write-Host -Object "The file $PathToGenerateJSON does not exist"
    }
} while (-not (Test-Path -Path $PathToGenerateJSON))

# Get the JSON data
$ADConfig = Get-Content -Path $PathToGenerateJSON | ConvertFrom-Json

$NewName = Read-Host -Prompt "Enter the new name for the domain controller"

# Update the JSON file
[string]$Content = ""

# Add each line of the JSON file to the content variable
Get-Content -Path $PathToGenerateJSON | ForEach-Object {
    $Content += $_ + "`n"
}

$Content = $Content.replace($ADConfig.Forest.DomainController.Name, $NewName)

# Create a new domain controller object
$DC = [DC]::new($ADConfig.Forest.DomainController.Name, $ADConfig.Forest.DomainController.Site, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.CN1 + "." + $ADConfig.Forest.CN2, $ADConfig.Forest.DomainController.OSVersion, $ADConfig.Forest.DomainController.InstallDNS, $Adapters, $false)

# Rename the domain controller
$DC.Rename()