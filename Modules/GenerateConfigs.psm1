# Function to generate the JSON file for the AD configuration
function GenerateADConfigFile ($ProjectRoot) {
    # Generate a random id for the config file
    $IdConfigFile = [System.Guid]::NewGuid().ToString()

    # Take The 5 first characters of the id
    $IdConfigFile = $IdConfigFile.Substring(0, 5)
    $PathToGenerateJSON = $ProjectRoot + "\Resources\Config\config-ad-" + $IdConfigFile +".json"

    $ResourcesPath = $ProjectRoot + "\Resources"
    $ConfigPath = $ResourcesPath + "\Config"

    # Check if folders exist
    if((Test-Path $ResourcesPath) -eq $false) {
        New-Item -ItemType Directory -Path $ResourcesPath
    }

    if((Test-Path $ConfigPath) -eq $false) {
        New-Item -ItemType Directory -Path $ConfigPath
    }

    # ----------------- CN -----------------

    # Choose the CN
    $CNname = Read-Host -Prompt "Choose the CN (Example : test.local))"

    # Check if the CN is not empty
    if ($CNname -eq "") {
        Write-Host "The CN cannot be empty. Please try again."
        GenerateADConfigFile $ProjectRoot
    }

    # Check if the CN is in the right format (CN1.CN2)
    $CNArray = $CNname.Split(".")
    if ($CNArray.Length -ne 2) {
        Write-Host "The CN must be in the format CN1.CN2. Please try again."
        GenerateADConfigFile $ProjectRoot
    }
    
    # ----------------- Description -----------------

    # Choose the description
    $Description = Read-Host -Prompt "Choose the description"
    

    # ----------------- Password -----------------

    # Choose a password for the SafeModeAdministrator (don't display the password in the console)
    do {
        $Password = Read-Host -Prompt "Choose a password for the SafeModeAdministrator" -AsSecureString
        $PasswordConfirm = Read-Host -Prompt "Confirm the password for the SafeModeAdministrator" -AsSecureString
    } while([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)) -ne [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordConfirm)))

    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    
    # Secure the password
    $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force
    
    # Display password chiffred
    $Password = ConvertFrom-SecureString -SecureString $Password

    # ----------------- Modes -----------------

    enum Mode {
        Win2000 = 0
        Win2003 = 1
        Win2008 = 2
        Win2008R2 = 3
        Win2012 = 4
        Win2012R2 = 5
        Win2016 = 6
        Win2019 = 7
    }

    # Choose the forest mode
    foreach ($mode in [Mode]::GetNames([Mode])) {
        Write-Host "$mode : $([int][Mode]$mode)"
    }

    do {
        do {
            $ForestMode = Read-Host -Prompt "Choose the forest mode"
        } while ($ForestMode -lt 0 -or $ForestMode -gt 7)

        # Choose the domain mode
        do {
            $DomainMode = Read-Host -Prompt "Choose the domain mode"
        } while ($DomainMode -lt 0 -or $DomainMode -gt 7)

        if ($DomainMode -lt $ForestMode) {
            Write-Host "The domain mode must be equal or higher than the forest mode. Please try again."
        }
    } while ($DomainMode -lt $ForestMode)

    # Message of success
    Write-Host "The forest mode is $([Mode]$ForestMode)"
    Write-Host "The domain mode is $([Mode]$DomainMode)"

    # ----------------- Domain Controller -----------------
  
    # List to store the domain controllers informations

    $DCName = hostname.exe
    
    # Choose the site of the domain controller
    $DCSite = Read-Host -Prompt "What's the site of the domain controller"

    # Choose the OS version of the domain controller
    $DCOSVersion = Read-Host -Prompt "What's the OS version of the domain controller"

    # Choose if the domain controller will install DNS
    enum InstallDNS {
        No = 0
        Yes = 1
    }

    foreach ($install_dns in [InstallDNS]::GetNames([InstallDNS])) {
        Write-Host "$install_dns : $([int][InstallDNS]$install_dns)"
    }

    $DCInstallDNS = 0

    $DCInstallDNSTemp = Read-Host -Prompt "Choose if the domain controller will install DNS (default: 0)"

    if($DCInstallDNSTemp -eq 0 -or $DCInstallDNSTemp -eq 1) {
        $DCInstallDNS = $DCInstallDNSTemp
    }

    # Convert the value to boolean
    $DCInstallDNS = [bool]$DCInstallDNS

    # Replication source domain controller
    $DCReplicationSourceDC = $DCName

    # ----------------- Network adapters -----------------

    # Ask the user to choose the network adapters
    
    # Display only the name of the network adapters
    $NetAdapters = Get-NetAdapter | Select-Object -ExpandProperty Name
    Write-Host "Network adapters : "
    foreach ($NetAdapter in $NetAdapters) {
        Write-Host $NetAdapter
    }


    do {
        $NetworkAdapterName = Read-Host -Prompt "What's the name of the network adapter"
        
        # Check if the network adapter exists in the list of network adapters
        if($NetAdapters -notcontains $NetworkAdapterName) {
            Write-Host "The network adapter does not exist. Please try again."
        } else {
            $NetworkAdapter = Get-NetAdapter -Name $NetworkAdapterName
        }
    } while ($NetAdapters -notcontains $NetworkAdapterName)

    # Ask the user to choose the IP address
    do {
        $NetworkAdapterIP = Read-Host -Prompt "What's the IP address of the network adapter"
        $NetworkAdapterIP = [IPAddress]$NetworkAdapterIP

        if ($NetworkAdapterIP -eq $null) {
            Write-Host "The IP address is not valid. Please try again."
        }
    } while ($NetworkAdapterIP -eq $null)

    # Ask the user to choose the prefix length
    do {
        $NetworkAdapterPrefixLength = Read-Host -Prompt "What's the prefix length of the network adapter"
        $NetworkAdapterPrefixLength = [int]$NetworkAdapterPrefixLength

        if ($NetworkAdapterPrefixLength -lt 0 -or $NetworkAdapterPrefixLength -gt 32) {
            Write-Host "The prefix length must be between 0 and 32. Please try again."
        }
    } while ($NetworkAdapterPrefixLength -lt 0 -or $NetworkAdapterPrefixLength -gt 32)

    # Ask the user to choose the default gateway
    do {
        $NetworkAdapterDefaultGateway = Read-Host -Prompt "What's the default gateway of the network adapter"
        $NetworkAdapterDefaultGateway = [IPAddress]$NetworkAdapterDefaultGateway

        if ($NetworkAdapterDefaultGateway -eq $null) {
            Write-Host "The default gateway is not valid. Please try again."
        }
    } while ($NetworkAdapterDefaultGateway -eq $null)

    # Ask the user to choose the DNS server
    do {
        $NetworkAdapterDNSServer = Read-Host -Prompt "What's the DNS server of the network adapter"
        $NetworkAdapterDNSServer = [IPAddress]$NetworkAdapterDNSServer

        if ($NetworkAdapterDNSServer -eq $null) {
            Write-Host "The DNS server is not valid. Please try again."
        }
    } while ($NetworkAdapterDNSServer -eq $null)

    # ----------------- JSON file -----------------

    # Create the JSON file
    Write-Host "Creating JSON file for AD configuration at : $PathToGenerateJSON"

    # Write in the JSON file
    $JSONContent = '{
    "Forest": 
    {
        "CN1": "'+$CNArray[0]+'",
        "CN2": "'+$CNArray[1]+'",
        "Description": "'+$Description+'",
        "SafeModeAdministratorPassword": "'+$Password+'",
        "ForestMode": "'+$ForestMode+'",
        "DomainMode": "'+$DomainMode+'",
        "DomainController": {
            "Name": "'+$DCName+'",
            "Site": "'+$DCSite+'",
            "OSVersion": "'+$DCOSVersion+'",
            "InstallDNS": "'+$DCInstallDNS+'",
            "ReplicationSourceDC": "'+$DCReplicationSourceDC+'",
            "NetAdapter": {
                "Name": "'+$NetworkAdapterName+'",
                "IPAddress": "'+$NetworkAdapterIP+'",
                "PrefixLength": "'+$NetworkAdapterPrefixLength+'",
                "DefaultGateway": "'+$NetworkAdapterDefaultGateway+'",
                "DNSServer": "'+$NetworkAdapterDNSServer+'"
            } 
        }
    }
}'

    $JSONContent | Out-File -FilePath $PathToGenerateJSON -Encoding ascii

    # Message of success
    Write-Host "JSON file for AD configuration created successfully at : $PathToGenerateJSON"

    # Return the path to the JSON file
    return $PathToGenerateJSON
}
