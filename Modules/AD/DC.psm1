using module ./Modules/Core/NetworkAdapter.psm1
using module ./Modules/Devices/Server.psm1

# Class to represent a domain controller
class DC : Server {
    # Public properties
    [string]$Site
    [string]$SafeModeAdministratorPassword
    [bool]$InstallDNS

    # Constructors
    DC([string]$Name, [string]$Site, [string]$Domain, [string]$Forest, [string]$OS, [bool]$InstallDNS, [NetworkAdapter[]]$NetworkAdapters, [bool]$Do_Install = $true) {
        $this.Name = $Name
        $this.Site = $Site
        $this.Domain = $Domain
        $this.Forest = $Forest
        $this.OS = $OS
        $this.InstallDNS = $InstallDNS
        $this.NetworkAdapters = $NetworkAdapters

        # Install DNS Server role if needed
        if ($this.InstallDNS -and $Do_Install) {
            Write-Host "Installing DNS Server role..."
            Install-WindowsFeature -Name DNS -IncludeManagementTools
        }
    }

    DC([string]$Name, [string]$Site, [string]$Domain, [string]$Forest, [string]$OS, [bool]$InstallDNS, [NetworkAdapter[]]$NetworkAdapters) {
        $this.Name = $Name
        $this.Site = $Site
        $this.Domain = $Domain
        $this.Forest = $Forest
        $this.OS = $OS
        $this.InstallDNS = $InstallDNS
        $this.NetworkAdapters = $NetworkAdapters

        # Install DNS Server role if needed
        if ($this.InstallDNS) {
            Write-Host "Installing DNS Server role..."
            Install-WindowsFeature -Name DNS -IncludeManagementTools
        }
    }
}