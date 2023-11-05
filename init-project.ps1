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


