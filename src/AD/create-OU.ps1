using module ../../Modules/AD/OU.psm1

# Ask for the name of the OU
$Name = Read-Host -Prompt "Enter the name of the OU"

$Path = Read-Host -Prompt "Enter the path of the OU (format: OU=,DC=,DC=)"


# Ask if the OU is protected or not
$Protected = Read-Host -Prompt "Is the OU protected from accidental deletion? (Y/N)"

if($Protected -eq "Y") {
    $Protected = $true
}
else {
    $Protected = $false
}

# Create the OU
$OU = [OU]::new($Path, $Name, $Protected)

# Add the OU
$OU.Create()
