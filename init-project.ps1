param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptToLaunchPath
)

# Use the console in administrator mode
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    
    # Relaunch the script in administrator mode and don't close the current window
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ScriptToLaunchPath `"$ScriptToLaunchPath`"" -Verb RunAs 

    Break
}

# Root of the project
$RootPath = "$PSScriptRoot"

# Place ourselves in the root of the project
Set-Location -Path $RootPath

# Path to the JSON file with the configuration for the modules
$JSONPathConfig = "$PSScriptRoot\Resources\Config\config.json"

# Import JSON file
$JSONConfig = Get-Content -Path $JSONPathConfig | ConvertFrom-Json

# Create a directory in Module directory to store .psd1 files if it doesn't exist
if (-not (Test-Path "$PSScriptRoot\Modules\psd1")) {
    New-Item -Path "$PSScriptRoot\Modules\psd1" -ItemType Directory
}


# Check all modules
foreach ($module in $JSONConfig.ModulePaths) {
    foreach($class in $module.Classes) {
        # Create a psd1 file for each module in $JSONConfig.ModulePaths
        $psd1Path = "$PSScriptRoot\Modules\psd1\$($class.Name).psd1"
        $psm1Path = "$PSScriptRoot$($module.Path)\$($class.Name).psm1"

        $psd1Content = "@{ `n`tModuleToProcess = '$psm1Path' `n`tPowerShellVersion = '5.1' `n}"
        $psd1Content | Out-File -FilePath $psd1Path -Encoding ascii
    }
}


# Verify the path of the script to execute
if ($ScriptToLaunchPath -notlike "$PSScriptRoot*") {
    $scriptPath = "$PSScriptRoot\src\$ScriptToLaunchPath"
}
else {
    $scriptPath = "$ScriptToLaunchPath"
}

# Execute the script
& $scriptPath

# Wait for the user to press a key
Read-Host -Prompt "Press Enter to exit"


