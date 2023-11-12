using module ../../Modules/AD/ADDS.psm1

# Check if ADDS is installed
$installed = [ADDS]::IsInstalled()

Write-Host "AD-Domain-Services installed: $installed"

if($installed) {
    # Check if want to install the module for AD powershell cmdlets on a remote computer if there is more than one computer in the domain
    try {
        $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
        
        # Check if there is more than one computer in the domain
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
    }
    catch {
        Write-Host "Error while getting the list of computers in the domain"
        Write-Host $_.Exception.Message
        Break
    }
}