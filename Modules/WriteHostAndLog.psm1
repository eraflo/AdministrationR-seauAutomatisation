# Module with only one function: Write-HostAndLog
function Write-HostAndLog {
    param (
        [string]$Message
    )

    # Write the message to the console
    Write-Host $Message
    # Write the message to the log file
    Add-Content -Path $global:LogFilePath -Value $Message
}
