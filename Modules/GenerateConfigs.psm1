# Function to generate the JSON file for the AD configuration
function GenerateADConfigFile ($ProjectRoot) {
    # Generate a random id for the config file
    $IdConfigFile = [System.Guid]::NewGuid().ToString()
    $PathToGenerateJSON = $ProjectRoot + "\Resources\Config\config-ad" + $IdConfigFile +".json"

    # ----------------- CN -----------------

    # Choose the CN
    $CN = Read-Host -Prompt "Choose the CN"

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
    $CNAlreadyUsed = Get-ADForest | Where-Object {$_.Name -eq $CN}
    if ($CNAlreadyUsed -ne $null) {
        Write-Host "The CN is already used. Please try again."
        GenerateADConfigFile $ProjectRoot
    }
    
    # ----------------- Description -----------------

    # Choose the description
    $Description = Read-Host -Prompt "Choose the description"
    

    # ----------------- Password -----------------

    # Choose a password for the SafeModeAdministrator
    $Password = Read-Host -Prompt "Choose a password for the SafeModeAdministrator"
    $PasswordConfirm = Read-Host -Prompt "Confirm the password for the SafeModeAdministrator"

    # Check if the passwords are the same
    if ($Password -ne $PasswordConfirm) {
        Write-Host "The passwords are not the same. Please try again."
        GenerateADConfigFile $ProjectRoot
    }

    # Secure the password
    $Password = ConvertTo-SecureString -String $Password -AsPlainText -Force

    # ----------------- Modes -----------------

    enum Mode {
        "Win2000" = 0,
        "Win2003" = 1,
        "Win2008" = 2,
        "Win2008R2" = 3,
        "Win2012" = 4,
        "Win2012R2" = 5,
        "Win2016" = 6,
        "Win2019" = 7
    }

    # Choose the forest mode
    foreach ($mode in [Mode]::GetNames([Mode])) {
        Write-Host "$mode : $([Mode]$mode)"
    }

    do {
        $ForestMode = Read-Host -Prompt "Choose the forest mode"
    } while ($ForestMode -lt 0 -or $ForestMode -gt 7)

    # Choose the domain mode
    do {
        $DomainMode = Read-Host -Prompt "Choose the domain mode"
    } while ($DomainMode -lt 0 -or $DomainMode -gt 7)

    # Check if the domain mode is higher than the forest mode
    if ($DomainMode -lt $ForestMode) {
        Write-Host "The domain mode cannot be lower than the forest mode. Please try again."
        GenerateADConfigFile $ProjectRoot
    }

    # Message of success
    Write-Host "The forest mode is $([Mode]$ForestMode)"
    Write-Host "The domain mode is $([Mode]$DomainMode)"


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
        "DomainControllers": [
            {
                "Name": "",
                "IPAddress": "",
                "OSVersion": ""
            }
        ]
    }
}'
    $JSONContent | Out-File -FilePath $PathToGenerateJSON -Encoding ascii
}
