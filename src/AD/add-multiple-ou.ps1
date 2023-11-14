using module ../../Modules/AD/OU.psm1

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
    $Name = $Row.OUName
    $Path = $Row.OUPath
    $Protected = $Row.Protected


    if($Protected -eq "Y" -or $Protected -eq "y" -or $Protected -eq "Yes" -or $Protected -eq "yes") {
        $Protected = $true
    }
    else {
        $Protected = $false
    }

    # Create the OU
    $OU = [OU]::new($Path, $Name, $Protected)

    # Add the OU
    $OU.Create()
}