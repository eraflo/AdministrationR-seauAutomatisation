using Module ./Modules/Core/Service.psm1

# Class for Active Directory Domain Services
class ADDS : Service {

    # ----------------- Public functions -----------------

    # Implement the constructor
    ADDS() {
        $this.Name = "ADDS"
        $this.Description = "Active Directory Domain Services (ADDS) is a directory service from Microsoft that stores information about objects on a network and makes this information available to users and network administrators."
        $this.Path = "C:\Windows\System32\ntds.exe"
        $this.Status = [Service.Statuts]::Stopped

        $this.Install()
        $this.Start()
    }

    # Implement the Start method
    [void]Start() {
        Write-Host "Starting Active Directory Domain Services..."
        Start-Service -Name "NTDS"
        $this.Status = [Service.Statuts]::Running
    }

    # Implement the Stop method
    [void]Stop() {
        Write-Host "Stopping Active Directory Domain Services..."
        Stop-Service -Name "NTDS"
        $this.Status = [Service.Statuts]::Stopped
    }

    # Implement the Restart method
    [void]Restart() {
        Write-Host "Restarting Active Directory Domain Services..."
        Restart-Service -Name "NTDS"
        $this.Status = [Service.Statuts]::Running
    }

    # Create a new forest
    [void]CreateForest($Name, $DomainMode, $ForestMode, $Password) {
        Write-Host "Creating a new forest..."
        
        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        # Create the new forest
        Install-ADDSForest -DomainName $Name -DomainMode $DomainMode -ForestMode $ForestMode -SafeModeAdministratorPassword $Password -Force:$true

        # Message of success
        Write-Host "New forest created successfully"

        # Restart the computer
        Write-Host "Restarting the computer..."
        Restart-Computer -Force
    }

    # Create a new domain
    [void]CreateDomain($Name, $ParentDomain, $DomainMode, $Password) {
        Write-Host "Creating a new domain..."
        
        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        # Create the new domain
        Install-ADDSDomain -DomainName $Name -ParentDomainName $ParentDomain -DomainMode $DomainMode -SafeModeAdministratorPassword $Password -Force:$true

        # Message of success
        Write-Host "New domain created successfully"

        # Restart the computer
        Write-Host "Restarting the computer..."
        Restart-Computer -Force
    }

    # ----------------- Private functions -----------------

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

            # Restart the computer
            Write-Host "Restarting the computer..."
            Restart-Computer -Force
        }
        else {
            # Message to inform that the ADDS role is already installed
            Write-Host "Active Directory Domain Services is already installed"
        }

    }
    

}