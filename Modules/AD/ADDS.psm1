using Module ../Core/Service.psm1
using Module ./ADLDS.psm1
using Module ./DC.psm1

# Class for Active Directory Domain Services
class ADDS : Service {

    hidden [ADLDS]$AD_LDS
    hidden [string]$DatabasePath = "C:\Windows\NTDS"
    hidden [string]$LogPath = "C:\Windows\NTDS"
    hidden [string]$SYSVOLPath = "C:\Windows\SYSVOL"


    # ----------------- Public properties -----------------

    # List of domain controllers
    [DC[]]$DCs

    # List of forests
    [string[]]$Forests

    # ----------------- Static properties -----------------
    [bool] static $IsInstalled = $false


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
            Write-HostAndLog "Starting Active Directory Domain Services..."
            Start-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Running
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while starting Active Directory Domain Services"
            Write-HostAndLog $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Stopped
            exit
        }
    }

    # Implement the Stop method
    [void]Stop() {
        try {
            Write-HostAndLog "Stopping Active Directory Domain Services..."
            Stop-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Stopped
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while stopping Active Directory Domain Services"
            Write-HostAndLog $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Running
            exit
        }
    }

    # Implement the Restart method
    [void]Restart() {
        try {
            Write-HostAndLog "Restarting Active Directory Domain Services..."
            Restart-Service -Name "NTDS"
            [ADDS]::Statut = [Statuts]::Running
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while restarting Active Directory Domain Services"
            Write-HostAndLog $_.Exception.Message
            [ADDS]::Statut = [Statuts]::Stopped
            exit
        }
    }

    # Promote a server to a domain controller
    [void]Promote([DC]$DC) {
        Write-HostAndLog "Promoting a server to a domain controller..."

        # Check if the domain controller exists
        if ($this.DCs -contains $DC) {
            # Message of error
            Write-HostAndLog "Error while promoting the server"
            Write-HostAndLog "The domain controller $($DC.Name) already exists"
            exit
        }

        # Get the domain controller
        $DomainController = $this.DCs | Where-Object { $_.Name -eq $DC }

        $SafeModeAdministratorPassword = $null

        # Ask for the SafeModeAdministratorPassword
        do {
            $SafeModeAdministratorPassword = Read-Host -Prompt "What's the SafeModeAdministratorPassword" -AsSecureString
            
            # Check if not null
            if ($SafeModeAdministratorPassword -eq $null) {
                Write-HostAndLog "The SafeModeAdministratorPassword is not valid. Please try again."
            }
            
            # Confirmation of the password
            $Confirm = Read-Host -Prompt "Confirm the SafeModeAdministratorPassword" -AsSecureString

            # Check if the passwords are the same by converting them to plain text
            $SafeModeAdministratorPassword = ConvertFrom-SecureString -SecureString $SafeModeAdministratorPassword
            $Confirm = ConvertFrom-SecureString -SecureString $Confirm

            if($SafeModeAdministratorPassword -ne $Confirm) {
                Write-HostAndLog "The passwords are not the same. Please try again."
            }

            $SafeModeAdministratorPassword = ConvertTo-SecureString -String $SafeModeAdministratorPassword -AsPlainText -Force
        } while ($SafeModeAdministratorPassword -eq $null)

        try {
            # Promote the server to a domain controller
            Install-ADDSDomainController -DomainName $DomainController.Domain -SiteName $DomainController.Site -ReplicationSourceDC $DomainController.ReplicationSourceDC -InstallDNS:$DomainController.InstallDNS -SafeModeAdministratorPassword $SafeModeAdministratorPassword -Force:$true -ErrorAction Stop

            # Message of success
            Write-HostAndLog "Server promoted successfully"

            # Add a new domain controller to the list
            $DC.SafeModeAdministratorPassword = $SafeModeAdministratorPassword.ToString()
            $this.DCs += $DC

            # Restart the computer
            Write-HostAndLog "Restarting the computer..."
            Restart-Computer -Force -ErrorAction Stop
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while promoting the server"
            Write-HostAndLog $_.Exception.Message
            exit
        }
    }

    # Create a new forest
    [void]CreateForest($Name, $DomainMode, $ForestMode, $ChiffredPassword) {
        Write-HostAndLog "Creating a new forest..."
        
        # Transform a chiffred password in a secure string
        $Password = ConvertTo-SecureString -String $ChiffredPassword


        try {
            #Get Netbios
            $Netbios = $Name.Split(".")[0]

            # Create the new forest
            Install-ADDSForest -NetBIOSName $Netbios -DomainMode $DomainMode -ForestMode $ForestMode -DatabasePath $this.DatabasePath -LogPath $this.LogPath -SYSVOLPath $this.SYSVOLPath -SafeModeAdministratorPassword $Password -Force:$true -ErrorAction Stop

            # Add a new forest to the list
            $this.Forests += $Name

            # Message of success
            Write-HostAndLog "New forest created successfully"
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while creating a new forest"
            Write-HostAndLog $_.Exception.Message
            exit
        }
    }

    # Create a new domain
    [void]CreateDomain($Name, $ParentDomain, $DomainMode, $Password) {
        Write-HostAndLog "Creating a new domain..."
        
        # Secure the password if it is not already
        if ($Password -isnot [securestring]) {
            $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
        }

        try {
            # Create the new domain
            Install-ADDSDomain -DomainName $Name -ParentDomainName $ParentDomain -DomainMode $DomainMode -SafeModeAdministratorPassword $Password -Force:$true -ErrorAction Stop

            # Message of success
            Write-HostAndLog "New domain created successfully"
        }
        catch {
            # Message of error
            Write-HostAndLog "Error while creating a new domain"
            Write-HostAndLog $_.Exception.Message
            exit
        }
    }

    # ----------------- Private functions -----------------

    # Implement the Install method
    hidden [void]Install() {
        Write-HostAndLog "Installing Active Directory Domain Services..."
        
        # Check if the ADDS role is installed
        $ADDSRole = Get-WindowsFeature -Name "AD-Domain-Services"
        if ($ADDSRole.Installed -eq $false) {
            try {
                # Install the ADDS role
                Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools -ErrorAction Stop

                [ADDS]::IsInstalled = $true

                # Message of success
                Write-HostAndLog "Active Directory Domain Services installed successfully"
            }
            catch {
                # Message of error
                Write-HostAndLog "Error while installing Active Directory Domain Services"
                Write-HostAndLog $_.Exception.Message
                exit
            }
        }
        else {
            # Message to inform that the ADDS role is already installed
            Write-HostAndLog "Active Directory Domain Services is already installed"
        }

    }
    

}