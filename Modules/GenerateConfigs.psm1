# Function to generate the JSON file for the AD configuration
function GenerateADConfigFile ($ProjectRoot) {
    # Generate a random id for the config file
    $IdConfigFile = [System.Guid]::NewGuid().ToString()
    $PathToGenerateJSON = $ProjectRoot + "\Resources\Config\config-ad" + $IdConfigFile +".json"

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
    $CN = Read-Host -Prompt "Choose the CN (Example : test.local))"

    # Check if the CN is not empty
    if ($CN -eq "") {
        Write-Host "The CN cannot be empty. Please try again."
        GenerateADConfigFile $ProjectRoot
    }

    # Check if the CN is in the right format (CN1.CN2)
    $CNArray = $CN.Split(".")
    if ($CNArray.Length -ne 2) {
        Write-Host "The CN must be in the format CN1.CN2. Please try again."
        GenerateADConfigFile $ProjectRoot
    }

    # Check if the CN is not already used
    # $CNAlreadyUsed = Get-ADForest | Where-Object {$_.Name -eq $CN}
    # if ($CNAlreadyUsed -ne $null) {
    #     Write-Host "The CN is already used. Please try again."
    #     GenerateADConfigFile $ProjectRoot
    # }
    
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
    do {
        $nb_dc = Read-Host -Prompt "How many domain controllers do you want to create ?"
        
        if ($nb_dc -lt 1) {
            Write-Host "You must create at least one domain controller. Please try again."
        }
    } while ($nb_dc -lt 1)
    

    # List to store the domain controllers informations
    $DCList = @()

    for($i = 0; $i -lt $nb_dc; $i++) {
        # Choose the name of the domain controller
        $DCName = Read-Host -Prompt "What's the name of the domain controller"

        # Choose the site of the domain controller
        $DCSite = Read-Host -Prompt "What's the site of the domain controller"

        # Choose the IP address of the domain controller
        $DCIPAddress = Read-Host -Prompt "What's the IP address of the domain controller"

        # Choose the OS version of the domain controller
        $DCOSVersion = Read-Host -Prompt "What's the OS version of the domain controller"

        # Choose if the domain controller will install DNS
        enum InstallDNS {
            Yes = 0
            No = 1
        }

        foreach ($install_dns in [InstallDNS]::GetNames([InstallDNS])) {
            Write-Host "$install_dns : $([int][InstallDNS]$install_dns)"
        }

        do {
            $DCInstallDNS = Read-Host -Prompt "Choose if the domain controller will install DNS"

            if ($DCInstallDNS -lt 0 -or $DCInstallDNS -gt 1) {
                Write-Host "The value must be 0 or 1. Please try again."
            }
        } while ($DCInstallDNS -lt 0 -or $DCInstallDNS -gt 1)

        # Choose the replication source domain controller
        if($nb_dc -gt 1) {
            do {
                $DCReplicationSourceDC = Read-Host -Prompt "What's the replication source domain controller"
            } while ($DCReplicationSourceDC -eq "" -or $DCList -notcontains $DCReplicationSourceDC)
        }
        else {
            $DCReplicationSourceDC = $DCName
        }

        # Add the domain controller to the list
        $DCList += [PSCustomObject]@{
            Name = $DCName
            Site = $DCSite
            IPAddress = $DCIPAddress
            OSVersion = $DCOSVersion
            InstallDNS = $DCInstallDNS
            ReplicationSourceDC = $DCReplicationSourceDC
        }
    }


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
        "DomainControllers": ['
            


    # Add the domain controllers to the JSON file
    foreach ($DC in $DCList) {
        $JSONContent = $JSONContent.Insert($JSONContent.Length, '{
            "Name": "'+$DC.Name+'",
            "Site": "'+$DC.Site+'",
            "IPAddress": "'+$DC.IPAddress+'",
            "OSVersion": "'+$DC.OSVersion+'",
            "InstallDNS": "'+$DC.InstallDNS+'",
            "ReplicationSourceDC": "'+$DC.ReplicationSourceDC+'"
        },')
    }

    # Remove the last comma
    $JSONContent = $JSONContent.Remove($JSONContent.Length - 1, 1)

    # Add the end of the JSON file
    $JSONContent = $JSONContent.Insert($JSONContent.Length, ']
    }
}')

    $JSONContent | Out-File -FilePath $PathToGenerateJSON -Encoding ascii

    # Message of success
    Write-Host "JSON file for AD configuration created successfully at : $PathToGenerateJSON"

    # Return the path to the JSON file
    return $PathToGenerateJSON
}
