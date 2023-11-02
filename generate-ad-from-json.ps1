# Generation of Active Directory objects from JSON file

# Import JSON file
$JSON = Get-Content -Path .\ad-informations.json | ConvertFrom-Json

# Generate a domain
New-ADReplicationSite -Name $JSON.Domain.Name -Description $JSON.Domain.Description

# Display the domain informations
Get-ADReplicationSite -Identity $JSON.Domain.Name