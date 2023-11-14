using module ../../Modules/AD/Group.psm1

# Ask for csv file
$CsvFile = Join-Path $RootPath "Resources"
$CsvFile = Join-Path $CsvFile "Data"
$CsvFile = Join-Path $CsvFile (Read-Host -Prompt "Enter the name of the csv file")

# Check if csv file exists
if(-not (Test-Path $CsvFile)) {
    Write-HostAndLog -Message "The csv file $CsvFile does not exist"
    exit
}

# Read csv file
$Csv = Import-Csv $CsvFile -Delimiter ";" -Encoding UTF8 

# Create each OU
foreach($Row in $Csv) {
    $GroupName = $Row.GroupName
    $Path = $Row.GroupPath
    $Scope = $Row.GroupScope
    $Type = $Row.GroupCategory
    $Description = $Row.GroupDescription

    
    # Create the group
    $Group = [Group]::new($Path, $GroupName, $Scope, $Type, $Description, $Members)

    # Add the group
    $Group.Create()
}