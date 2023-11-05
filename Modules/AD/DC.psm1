using module ./Modules/Core/NetworkAdapter.psm1

# Class to represent a domain controller
class DC {
    # Public properties
    [string]$Name
    [string]$Site
    [string]$Domain
    [string]$Forest
    [string]$OS
    [string]$SafeModeAdministratorPassword
    [bool]$InstallDNS
    [NetworkAdapter[]]$NetworkAdapters

    # Constructor
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

    # Rename the computer
    [void]Rename() {
        Write-Host "Renaming computer to $($this.Name)..."
        Rename-Computer -NewName $this.Name -Force -Restart
    }
}