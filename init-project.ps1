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

# Install the module for AD powershell cmdlets
if(-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Installing the module for AD powershell cmdlets..."
    Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
}
# Root of the project
$RootPath = "$PSScriptRoot"

# Place ourselves in the root of the project
Set-Location -Path $RootPath

# Verify the path of the script to execute
if ($ScriptToLaunchPath -notlike "$PSScriptRoot*") {
    $scriptPath = "$PSScriptRoot\src\$ScriptToLaunchPath"
}
else {
    $scriptPath = "$ScriptToLaunchPath"
}

# Generate a Log Directory
$LogDirectory = "$RootPath\logs"
if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory
}

# Generate a log file for this script each day
$LogFilePath = "$LogDirectory\$(Get-Date -Format 'yyyy-MM-dd')" + "_$(Split-Path -Path $scriptPath -Leaf).log"
if(-not (Test-Path -Path $LogFilePath)) {
    New-Item -Path $LogFilePath -ItemType File
}

# Execute the script
Write-Host "Executing the script $scriptPath"
Write-Host "Log file: $LogFilePath"

# Execute the script and redirect the output to the log file
& $scriptPath 2>&1 | Tee-Object -FilePath $LogFilePath

# Wait for the user to press a key
Read-Host -Prompt "Press Enter to exit"


