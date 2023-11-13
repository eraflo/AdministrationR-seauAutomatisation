using module ../../Modules/AD/OU.psm1

# Ask for the name of the OU
$Name = Read-Host -Prompt "Enter the name of the OU"

# Ask if create at root
$AtRoot = Read-Host -Prompt "Create at root? (Y/N)"

if($AtRoot -eq "Y") {
    $AtRoot = $true
}
else {
    $AtRoot = $false
}


$Path = Read-Host -Prompt "Enter the path of the OU (format: OU=,DC=,DC=)"


# Check if not only Dc= , DC= in path when $AtRoot is $true
if($AtRoot -eq $false -and $Path -notmatch "OU=") {
    Write-HostAndLog -Message "The path must start with OU=" 
    exit
}


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
$OU.Create($AtRoot)
