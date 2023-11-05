using module ./Modules/WriteHostAndLog.psm1
param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptToLaunchPath
)

# Update powershell
if($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Updating powershell..."
    try {
        iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
    }
    catch {
        Write-Host "Error while updating powershell"
        Write-Host $_.Exception.Message
        Break
    }
}

if($IsWindows) {
    # Commande to run as administrator on Windows
    $runAdmin = "Start-Process powershell -Verb runAs -ArgumentList '-NoExit', '-File', '$PSCommandPath', '$ScriptToLaunchPath'"
}
elseif ($IsLinux) {
    $runAdmin = "sudo pwsh -NoExit -File $PSCommandPath $ScriptToLaunchPath"
}

# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "The script is not running as administrator"
    Write-Host "Restarting the script as administrator..."
    Invoke-Expression $runAdmin
    Break
}


# Install the module for AD powershell cmdlets
if(-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Installing the module for AD powershell cmdlets..."
    Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature
}

# Check if want to install the module for AD powershell cmdlets on a remote computer if there is more than one computer in the domain
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
if ($computers.Count -gt 1) {
    Write-Host "Do you want to install the module for AD powershell cmdlets on a remote computer ? (y/n)"
    
    $answer = Read-Host
    
    if ($answer -eq "y") {
        # Display the list of computers in the domain
        Write-Host "List of computers in the domain:"
        foreach ($computer in $computers) {
            Write-Host $computer
        }

        # Ask the name of the computer on which we want to install the module for AD powershell cmdlets
        Write-Host "Enter the name of the computer on which you want to install the module for AD powershell cmdlets"
        $computerName = Read-Host

        # Check if the computer exists in the domain
        if ($computers -contains $computerName) {
            Write-Host "Installing the module for AD powershell cmdlets on $computerName..."
            Invoke-Command -ComputerName $computerName -ScriptBlock { Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeAllSubFeature }
        }
        else {
            Write-Host "The computer $computerName does not exist in the domain"
        }
    }
}

# Root of the project
$global:RootPath = "$PSScriptRoot"

# Place ourselves in the root of the project
Set-Location -Path $RootPath

# Verify the path of the script to execute
if ($ScriptToLaunchPath -notlike "$PSScriptRoot*") {
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "src"
    $scriptPath = Join-Path -Path $scriptPath -ChildPath $ScriptToLaunchPath
}
else {
    $scriptPath = "$ScriptToLaunchPath"
}

# Generate a Log Directory
$LogDirectory = Join-Path -Path $RootPath -ChildPath "logs"
if (-not (Test-Path -Path $LogDirectory)) {
    New-Item -Path $LogDirectory -ItemType Directory
}

# Generate a log file for this script each day
$global:LogFilePath = Join-Path -Path $LogDirectory -ChildPath ""
$global:LogFilePath = "$global:LogFilePath" + "$(Get-Date -Format 'yyyy-MM-dd')" + "_$($(Split-Path -Path $scriptPath -Leaf).Replace('.ps1','')).log"
if(-not (Test-Path -Path $LogFilePath)) {
    New-Item -Path $LogFilePath -ItemType File
}

# Restart variable to know if we need to restart the computer
$global:restart = $false

# Execute the script
Write-Host "Executing the script $scriptPath"
Write-Host "Log file: $LogFilePath"

# Execute the script and redirect the output to the log file
& $scriptPath 


# Restart the computer if needed
if ($restart) {
    Write-Host "Restarting the computer..."
    Restart-Computer
}


