

# Class to represent a network adapter
class NetworkAdapter {
    # Public properties
    [string]$Name
    [IPAddress]$IPAddress
    [int]$PrefixLength = 24
    [IPAddress]$DefaultGateway
    [IPAddress[]]$DNSServers

    # Constructor

    # Static IP
    NetworkAdapter([string]$Name, [IPAddress]$IPAddress, [int]$PrefixLength, [IPAddress]$DefaultGateway, [IPAddress[]]$DNSServers) {
        # Verify the network adapter exists
        if((Get-NetAdapter -Name $Name).Name -eq $null) {
            Write-HostAndLog "The network adapter $Name doesn't exist. Please try again."
            exit
        }

        # Verify the PrefixLength is valid
        $this.CheckPrefixLength($PrefixLength)
        
        $this.Name = $Name
        $this.IPAddress = $IPAddress
        $this.PrefixLength = $PrefixLength
        $this.DefaultGateway = $DefaultGateway
        foreach($DNSServer in $DNSServers) {
            $this.DNSServers += $DNSServer
        }

        $this.SetIPAddress($this.IPAddress, $this.PrefixLength, $this.DefaultGateway)
        $this.SetDNSServers($this.DNSServers)
    }

    
    NetworkAdapter([string]$Name) {
        # Verify the network adapter exists
        if((Get-NetAdapter -Name $Name).Name -eq $null) {
            Write-HostAndLog "The network adapter $Name doesn't exist. Please try again."
            exit
        }

        $this.Name = $Name
        
        # Retrieve the network adapter configuration with the name

        # IPv4
        $this.IPAddress = (Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).IPAddress[1]
        $this.PrefixLength = (Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).PrefixLength[0]
        $this.DefaultGateway = (Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).DefaultGateway[0]

        # Retrieve the DNS servers
        foreach($DNSServer in (Get-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).ServerAddresses) {
            $this.DNSServers += $DNSServer
        }
    }


    # Set IP address
    [void]SetIPAddress([IPAddress]$IPAddress, [int]$Prefix, [IPAddress]$DefaultGateway) {
        Write-HostAndLog "Setting IP address of the network adapter..."

        # Check PrefixLength is valid
        $this.CheckPrefixLength($Prefix)

        # Check if not the same IP address
        if((Get-NetIPAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).IPAddress -eq $IPAddress) {
            Write-HostAndLog "The IP address is already set."
            return
        }

        try {
            New-NetIPAddress -IPAddress $IPAddress -PrefixLength $this.PrefixLength -DefaultGateway $DefaultGateway -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex
        }
        catch {
            Write-HostAndLog "An error occured while setting the IP address. Please try again."
            exit
        }
    }

    # Set DNS server
    [void]SetDNSServers([IPAddress[]]$DNSServers) {
        Write-HostAndLog "Setting DNS server of the network adapter..."
        
        # Check if not the same DNS server
        if((Get-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex).ServerAddresses -eq $DNSServers) {
            Write-HostAndLog "The DNS server is already set. Please try again."
            return
        }

        try {
            Set-DnsClientServerAddress -ServerAddresses $DNSServers -InterfaceIndex (Get-NetAdapter -Name $this.Name).ifIndex
        }
        catch {
            Write-HostAndLog "An error occured while setting the DNS server. Please try again."
            exit
        }
    }

    hidden [bool]CheckPrefixLength([int]$PrefixLength) {
        if($PrefixLength -lt 0 -or $PrefixLength -gt 32) {
            Write-HostAndLog "The PrefixLength must be between 0 and 32. Please try again."
            return $false
        }
        else {
            return $true
        }
    }
}