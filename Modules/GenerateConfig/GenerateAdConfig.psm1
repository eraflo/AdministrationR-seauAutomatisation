
# Function to generate the JSON file for the AD configuration
function GenerateADConfigFile ($ProjectRoot) {
    # Generate a random id for the config file
    $IdConfigFile = [System.Guid]::NewGuid().ToString()
    $PathToGenerateJSON = $ProjectRoot + "\Resources\Config\config-ad" + $IdConfigFile +".json"

    # Create the JSON file
    Write-Host "Creating JSON file for AD configuration at : $PathToGenerateJSON"

    # Write in the JSON file
    $JSONContent = '{
        "Forest": 
        {
            "CN1": "",
            "CN2": "",
            "Description": "",
            "SafeModeAdministratorPassword": "",
            "ForestMode": "",
            "DomainMode": "",
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
