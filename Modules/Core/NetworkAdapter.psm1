

# Class to represent a network adapter
class NetworkAdapter {
    # Public properties
    [string]$Name
    [IPAddress]$IPAddress
    [int]$PrefixLength = 24
    [IPAddress]$DefaultGateway
    [IPAddress[]]$DNSServers

    # Constructor
    NetworkAdapter([string]$Name, [IPAddress]$IPAddress, [int]$PrefixLength, [IPAddress]$DefaultGateway, [IPAddress[]]$DNSServers) {
        # Verify the network adapter exists
        if((Get-NetAdapter -Name $Name).Name -eq $null) {
            Write-Host "The network adapter $Name doesn't exist. Please try again."
            exit
        }

        # Verify the PrefixLength is valid
        $this.CheckPrefixLength($PrefixLength)
        
        $this.Name = $Name
        $this.IPAddress = $IPAddress
        $this.PrefixLength = $PrefixLength
        $this.DefaultGateway = $DefaultGateway
        foreach($DNSServer in $DNSServers) {
            $this.DNSServer += $DNSServer
        }

        $this.SetIPAddress($this.IPAddress, $this.PrefixLength, $this.DefaultGateway)
        $this.SetDNSServers($this.DNSServers)
    }


    # Set IP address
    [void]SetIPAddress([IPAddress]$IPAddress, [int]$Prefix, [IPAddress]$DefaultGateway) {
        Write-Host "Setting IP address of the network adapter..."

        # Check PrefixLength is valid
        $this.CheckPrefixLength($Prefix)

        New-NetIPAddress -InterfaceAlias $this.Name -IPAddress $IPAddress -PrefixLength $this.PrefixLength -DefaultGateway $DefaultGateway -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex
    }

    # Set DNS server
    [void]SetDNSServers([IPAddress[]]$DNSServers) {
        Write-Host "Setting DNS server of the network adapter..."
        
        Set-DnsClientServerAddress -ServerAddresses $DNSServers -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex
    }

    hidden [bool]CheckPrefixLength([int]$PrefixLength) {
        if($PrefixLength -lt 0 -or $PrefixLength -gt 32) {
            Write-Host "The PrefixLength must be between 0 and 32. Please try again."
            return $false
        }
        else {
            return $true
        }
    }
}