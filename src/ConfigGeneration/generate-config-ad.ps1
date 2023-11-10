using module ../../Modules/GenerateConfigs.psm1

# Generate the JSON file for the AD configuration
$PathToGenerateJSON = GenerateADConfigFile($RootPath)
