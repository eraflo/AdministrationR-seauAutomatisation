using Module ./Modules/Core/Service.psm1

# Class for Active Directory Domain Services
class ADDS : Service {

    # public properties
    [string]$Name
    [string]$Description
    [string]$Statut

}