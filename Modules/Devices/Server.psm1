using module ./Modules/Core/NetworkAdapter.psm1

# Class representing a server
class Server {
    [string]$Name
    [string]$Domain
    [string]$Forest
    [string]$OS
    [NetworkAdapter[]]$NetworkAdapters

    # Constructor
    Server() {
        $this.Name = Get-Content env:computername
        $this.Domain = $null
        $this.Forest = $null
        $this.OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $this.NetworkAdapters += [NetworkAdapter]::new("Ethernet")
    }

    Server([string]$Name, [string]$Domain = $null, [string]$Forest = $null, [string]$OS, [NetworkAdapter[]]$NetworkAdapters) {
        $this.Name = $Name
        $this.Domain = $Domain
        $this.Forest = $Forest
        $this.OS = $OS
        $this.NetworkAdapters = $NetworkAdapters
    }

    # Add the server to the domain
    [void]AddToDomain($Domain) {
        Write-HostAndLog "Adding server to domain $($Domain)..."
        try {
            $this.Domain = $Domain
            Add-Computer -DomainName $this.Domain -Credential $this.Domain\Administrator -Restart
        }
        catch {
            Write-HostAndLog "Failed to add server to domain $($Domain)"
            Write-HostAndLog $_.Exception.Message
            exit 1
        }
    }


    # Rename the computer (Return true if need to restart)
    [bool]Rename() {
        $restart = $false

        Write-HostAndLog "Renaming server to $($this.Name)..."
        try {
            Rename-Computer -NewName $this.Name -Force
            Write-HostAndLog "Server renamed successfully"
            $restart = $true
        }
        catch {
            Write-HostAndLog "Failed to rename server to $($this.Name)"
            Write-HostAndLog $_.Exception.Message
            exit 1
        }
        return $restart
    }

}