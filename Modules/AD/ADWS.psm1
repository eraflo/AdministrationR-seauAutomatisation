using Module ./Modules/Core/Service.psm1

# Class for ADWS service
class ADWS : Service {

    # ----------------- Public functions -----------------

    # Implement the constructor
    ADWS() {
        $this.Name = "ADWS"
        $this.Description = "Active Directory Web Services (ADWS) provides a Web service interface to Active Directory domains, Active Directory Lightweight Directory Services (AD LDS) instances, and Active Directory Database Mounting Tool instances that are running on the same Windows Server 2008 R2 server as the ADWS service."
        $this.Path = "C:\Windows\System32\svchost.exe"
        [ADWS]::Statut = [Statuts]::Stopped

        $this.Install()
    }

    # Implement the Start method
    [void]Start() {
        Write-Host "Starting Active Directory Web Services..."
        Start-Service -Name "ADWS"
        [ADWS]::Statut = [Statuts]::Running
    }

    # Implement the Stop method
    [void]Stop() {
        Write-Host "Stopping Active Directory Web Services..."
        Stop-Service -Name "ADWS"
        [ADWS]::Statut = [Statuts]::Stopped
    }

    # Implement the Restart method
    [void]Restart() {
        Write-Host "Restarting Active Directory Web Services..."
        Restart-Service -Name "ADWS"
        [ADWS]::Statut = [Statuts]::Running
    }

    # ----------------- Private functions -----------------

    # Implement the Install method
    [void]Install() {
        Write-Host "Installing Active Directory Web Services..."
        Install-WindowsFeature -Name "ADWS" -IncludeManagementTools
        [ADWS]::Statut = [Statuts]::Stopped
    }
}