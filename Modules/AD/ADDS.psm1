using Module ./Modules/Core/Service.psm1

# Class for Active Directory Domain Services
class ADDS : Service {

    # Implement the constructor
    ADDS() {
        $this.Name = "ADDS"
        $this.Description = "Active Directory Domain Services (ADDS) is a directory service from Microsoft that stores information about objects on a network and makes this information available to users and network administrators."
        $this.Path = "C:\Windows\System32\ntds.exe"
        $this.Status = "Stopped"

        $this.Install()
    }

    # Implement the Start method
    [void]Start() {
        Write-Host "Starting Active Directory Domain Services..."
        Start-Service -Name "NTDS"
        $this.Status = "Running"
    }

    # Implement the Stop method
    [void]Stop() {
        Write-Host "Stopping Active Directory Domain Services..."
        Stop-Service -Name "NTDS"
        $this.Status = "Stopped"
    }

    # Implement the Restart method
    [void]Restart() {
        Write-Host "Restarting Active Directory Domain Services..."
        Restart-Service -Name "NTDS"
        $this.Status = "Running"
    }

    # Implement the Install method
    hidden [void]Install() {
        Write-Host "Installing Active Directory Domain Services..."
        
        # Check if the ADDS role is installed
        $ADDSRole = Get-WindowsFeature -Name "AD-Domain-Services"
        if ($ADDSRole.Installed -eq $false) {
            # Install the ADDS role
            Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools

            # Message of success
            Write-Host "Active Directory Domain Services installed successfully"
        }
        else {
            # Message to inform that the ADDS role is already installed
            Write-Host "Active Directory Domain Services is already installed"
        }

    }
    

}