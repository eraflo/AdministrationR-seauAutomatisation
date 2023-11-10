using module ../../Modules/AD/User.psm1

# Ask for a csv file
$csvFile = Read-Host "Enter the name of the csv file"

$csvFilePath = Join-Path -Path $global:RootPath -ChildPath "Ressources"
$csvFilePath = Join-Path -Path $csvFilePath -ChildPath "Data" 
$csvFile = Join-Path -Path $csvFilePath -ChildPath $csvFile 

# Check if the file exists
if (-not (Test-Path $csvFile)) {
    throw "The file $csvFile does not exist"
}

# Get the content of the csv file
$csvContent = Import-Csv $csvFile -Delimiter ";" -Encoding UTF8

# Ask for the CNs
$DC1 = Read-Host "Enter the first DC"
$DC2 = Read-Host "Enter the second DC"

# Check if the domain exists
if (-not (Get-ADDomain -Server ($DC1 + "." + $DC2))) {
    throw "The domain $DC1.$DC2 does not exist"
}

# Create the users
foreach ($user in $csvContent) {
    $user = [User]::new($user.FirstName, $user.Lastname, $user.Fonction, $DC1, $DC2)
    $user.Create()
}




