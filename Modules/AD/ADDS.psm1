using Module ./Modules/Core/Service.psm1
using Module ./Modules/AD/ADLDS.psm1
using Module ./Modules/AD/DC.psm1

# Class for Active Directory Domain Services
class ADDS : Service {

    hidden [ADLDS]$AD_LDS

    # ----------------- Public properties -----------------

    # List of domain controllers
    [DC[]]$DCs

    # List of forests
    [string[]]$Forests

    # ----------------- Public functions -----------------

    # Implement the constructor
    ADDS() {
        $this.Name = "ADDS"
        $this.Description = "Active Directory Domain Services (ADDS) is a directory service from Microsoft that stores information about objects on a network and makes this information available to users and network administrators."
        $this.Path = "C:\Windows\System32\ntds.exe"
        [ADDS]::Statut = [Statuts]::Stopped

        $this.AD_LDS = [ADLDS]::new()

        $this.Install()
    }

    # Implement the Start method
    [void]Start() {
        try {
            Write-Host "Starting Active Directory Domain Services..."
            Start-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Running
        }
        catch {
            # Message of error
            Write-Host "Error while starting Active Directory Domain Services"
            Write-Host $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Stopped
            exit
        }
    }

    # Implement the Stop method
    [void]Stop() {
        try {
            Write-Host "Stopping Active Directory Domain Services..."
            Stop-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Stopped
        }
        catch {
            # Message of error
            Write-Host "Error while stopping Active Directory Domain Services"
            Write-Host $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Running
            exit
        }
    }

    # Implement the Restart method
    [void]Restart() {
        try {
            Write-Host "Restarting Active Directory Domain Services..."
            Restart-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Running
        }
        catch {
            # Message of error
            Write-Host "Error while restarting Active Directory Domain Services"
            Write-Host $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Stopped
            exit
        }
    }

    # Promote a server to a domain controller
    [void]Promote($Name, [string]$Forest, $Domain, $Password, $Site, $ReplicationSourceDC, $InstallDNS, $DomainMode, $ForestMode) {
        Write-Host "Promoting a server to a domain controller..."

        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        # Check if forest exists
        if ($this.Forests -notcontains $Forest) {
            # Message of error
            Write-Host "Error while promoting the server"
            Write-Host "The forest $Forest does not exist"
            exit
        }

        # Check if the domain controller already exists
        if ($this.DCs -contains $Name) {
            # Message of error
            Write-Host "Error while promoting the server"
            Write-Host "The domain controller $Name already exists"
            exit
        }

        try {
            # Promote the server to a domain controller
            Install-ADDSDomainController -DomainName $Domain -Credential (Get-Credential -UserName $Domain -Message "Enter the credentials of the domain administrator") -SiteName $Site -ReplicationSourceDC $ReplicationSourceDC -InstallDNS:$InstallDNS -SafeModeAdministratorPassword $Password -Force:$true -ErrorAction Stop

            # Message of success
            Write-Host "Server promoted successfully"

            # Add a new domain controller to the list
            $this.DCs += [DC]::new($Name, $Site, $Domain, $Forest, (Get-ADDomainController -Identity $Name).OSVersion)

            # Restart the computer
            Write-Host "Restarting the computer..."
            Restart-Computer -Force -ErrorAction Stop
        }
        catch {
            # Message of error
            Write-Host "Error while promoting the server"
            Write-Host $_.Exception.Message
            exit
        }
    }

    # Create a new forest
    [void]CreateForest($Name, $DomainMode, $ForestMode, $Password) {
        Write-Host "Creating a new forest..."
        
        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        try {
            # Create the new forest
            Install-ADDSForest -DomainName $Name -DomainMode $DomainMode -ForestMode $ForestMode -SafeModeAdministratorPassword $Password -Force:$true -ErrorAction Stop

            # Add a new forest to the list
            $this.Forests += $Name

            # Message of success
            Write-Host "New forest created successfully"
        }
        catch {
            # Message of error
            Write-Host "Error while creating a new forest"
            Write-Host $_.Exception.Message
            exit
        }
    }

    # Create a new domain
    [void]CreateDomain($Name, $ParentDomain, $DomainMode, $Password) {
        Write-Host "Creating a new domain..."
        
        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        try {
            # Create the new domain
            Install-ADDSDomain -DomainName $Name -ParentDomainName $ParentDomain -DomainMode $DomainMode -SafeModeAdministratorPassword $Password -Force:$true -ErrorAction Stop

            # Message of success
            Write-Host "New domain created successfully"
        }
        catch {
            # Message of error
            Write-Host "Error while creating a new domain"
            Write-Host $_.Exception.Message
            exit
        }
    }

    # ----------------- Private functions -----------------

    # Implement the Install method
    hidden [void]Install() {
        Write-Host "Installing Active Directory Domain Services..."
        
        # Check if the ADDS role is installed
        $ADDSRole = Get-WindowsFeature -Name "AD-Domain-Services"
        if ($ADDSRole.Installed -eq $false) {
            try {
                # Install the ADDS role
                Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools -ErrorAction Stop

                # Message of success
                Write-Host "Active Directory Domain Services installed successfully"
            }
            catch {
                # Message of error
                Write-Host "Error while installing Active Directory Domain Services"
                Write-Host $_.Exception.Message
                exit
            }
        }
        else {
            # Message to inform that the ADDS role is already installed
            Write-Host "Active Directory Domain Services is already installed"
        }

    }
    

}