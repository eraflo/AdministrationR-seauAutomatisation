using Module ./Modules/Core/Service.psm1


# Class for AD LDS service
class ADLDS : Service {

    # ----------------- Public functions -----------------

    # Implement the constructor
    ADLDS() {
        $this.Name = "ADLDS"
        $this.Description = "Active Directory Lightweight Directory Services (AD LDS) is a Lightweight Directory Access Protocol (LDAP) directory service that provides flexible support for directory-enabled applications, without the dependencies that are required for Active Directory Domain Services (AD DS)."
        $this.Path = "C:\Windows\System32\lsass.exe"
        [ADLDS]::Statut = [Statuts]::Stopped

        $this.Install()
    }

    # Implement the Start method
    [void]Start() {
        Write-HostAndLog "Starting Active Directory Lightweight Directory Services..."
        Start-Service -Name "ADLDS"
        [ADLDS]::Statut = [Statuts]::Running
    }

    # Implement the Stop method
    [void]Stop() {
        Write-HostAndLog "Stopping Active Directory Lightweight Directory Services..."
        Stop-Service -Name "ADLDS"
        [ADLDS]::Statut = [Statuts]::Stopped
    }

    # Implement the Restart method
    [void]Restart() {
        Write-HostAndLog "Restarting Active Directory Lightweight Directory Services..."
        Restart-Service -Name "ADLDS"
        [ADLDS]::Statut = [Statuts]::Running
    }

    # ----------------- Private functions -----------------

    # Implement the Install method
    [void]Install() {
        Write-HostAndLog "Installing Active Directory Lightweight Directory Services..."
        Install-WindowsFeature -Name "ADLDS" -IncludeManagementTools
        [ADLDS]::Statut = [Statuts]::Stopped
    }
}