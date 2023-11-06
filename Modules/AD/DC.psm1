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
    [NetworkAdapter[]]$NetworkAdapters

    # Constructor
    DC([string]$Name, [string]$Site, [string]$Domain, [string]$Forest, [string]$OS, [NetworkAdapter[]]$NetworkAdapters) {
        $this.Name = $Name
        $this.Site = $Site
        $this.Domain = $Domain
        $this.Forest = $Forest
        $this.OS = $OS
        $this.NetworkAdapters = $NetworkAdapters
    }
}