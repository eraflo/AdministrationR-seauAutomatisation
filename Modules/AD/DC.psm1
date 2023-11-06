

# Class to represent a domain controller
class DC {
    # Public properties
    [string]$Name
    [string]$Site
    [string]$Domain
    [string]$Forest
    [string]$OS

    # Constructor
    DC([string]$Name, [string]$Site, [string]$Domain, [string]$Forest, [string]$OS) {
        $this.Name = $Name
        $this.Site = $Site
        $this.Domain = $Domain
        $this.Forest = $Forest
        $this.OS = $OS
    }
}