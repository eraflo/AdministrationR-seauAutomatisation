# Generation of Active Directory objects from JSON file
using module ./Modules/AD/ADDS.psm1
using module ./Modules/GenerateConfigs.psm1

GenerateADConfigFile($RootPath)