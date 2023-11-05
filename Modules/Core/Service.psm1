# Abstract class for AD services
class Service {
    # public properties
    [string]$Name
    [string]$Description
    [string]$Path
    [string]$Statut


    # As the abstract keyword is not available in PowerShell, we use a private constructor to prevent instantiation
    Service() {
        $type = $this.GetType()
        if ($type -eq [Service]) {
            throw "Cannot instantiate abstract class $type"
        }
    }

    # public methods
    [void]Start() {
        throw "Must override Start method"
    }

    [void]Stop() {
        throw "Must override Stop method"
    }

    [void]Restart() {
        throw "Must override Restart method"
    }

    # Install the service (private method)
    hidden [void]Install() {
        throw "Must override Install method"
    }
}

