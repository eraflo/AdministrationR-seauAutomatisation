using module ./Modules/Devices/Server.psm1
using module ./Modules/Core/NetworkAdapter.psm1

$NewName = Read-Host -Prompt "Enter the new name for the server"

# Create a server object
$Server = [Server]::new()

$Server.Name = $NewName

# Rename the domain controller
$global:restart = $Server.Rename()

