using Module ./Modules/Core/Service.psm1
using Module ./Modules/Devices/Server.psm1

# Class for DHCP service
class DHCP : Service {
    
    # Properties
    [Server]$Server
    
    # Constructor
    DHCP($Server) {
        
        # Init the properties of the parent class
        $this.Name = "DHCPServer"
        $this.Description = "DHCP Server"
        $this.Path = "C:\Windows\system32\dhcp"

        $this.Server = $Server
    }

    # Override the Start method
    [void]Start() {
        Write-Host "Starting DHCP service..."
        Start-Service -Name $this.Name
    }

    # Override the Stop method
    [void]Stop() {
        Write-Host "Stopping DHCP service..."
        Stop-Service -Name $this.Name
    }

    # Override the Uninstall method
    [void]Uninstall() {
        Write-Host "Uninstalling DHCP role..."
        Uninstall-WindowsFeature -Name DHCP -Remove
    }

    # Override the Install method
    [void]Install() {
        Write-Host "Installing DHCP role..."

        # Install the DHCP service
        try {
            Install-WindowsFeature -Name DHCP -IncludeManagementTools
        }
        catch {
            Write-Host "Failed to install DHCP role."
            Write-Host $_.Exception.Message
            exit
        }
    }

    # Method to autorize the DHCP server in the domain
    [void]Authorize($AdapterName, $Credential) {
        Write-Host "Authorizing DHCP server..."

        # Check if the DHCP service is installed
        if((Get-WindowsFeature -Name DHCP).Installed -eq $false) {
            Write-Host "The DHCP service is not installed. Please try again."
            exit
        }

        # Check if server is in a domain
        if($this.Server.Domain -eq $null) {
            Write-Host "The server is not in a domain. Please try again."
            exit
        }

        # Check if Adapter Name exist in the server
        $found = $false
        $ip = $null
        foreach($NetworkAdapter in $this.Server.NetworkAdapters) {
            if($NetworkAdapter.Name -eq $AdapterName) {
                $found = $true
                $ip = $NetworkAdapter.IPAddress
            }
        }

        if($found -eq $false) {
            Write-Host "The adapter name given in parameter does not exist on the server. Please try again."
            exit
        }

        # Authorize the DHCP server
        Write-Host "Authorizing DHCP server in AD..."
        try {
            Write-Host "Successfully authorized DHCP server."

            $DnsName = $this.Server.Name + "." + $this.Server.Domain

            Add-DhcpServerInDC -DnsName $DnsName -IPAddress $ip 
        }
        catch {
            Write-Host "Failed to authorize DHCP server."
            Write-Host $_.Exception.Message
            exit
        }
    }
    


}