function createModel
{
    Param(
        [parameter()]
        [string]$HostName = "localhost",

        [parameter()]
        [int]$Port = 5672,

        [parameter()]
        [string]
        [string]$UserName = "guest",

        [parameter()]
        [string]
        [string]$Password = "guest"
    )


    $modulePath = (Get-Module RabbitMQ-PowerShell-Client).ModuleBase

    [System.Reflection.Assembly]::LoadFile("$modulePath\RabbitMQ.Client.dll") | Out-Null

    $connectionFactory = New-Object RabbitMQ.Client.ConnectionFactory

    $hostnameProp = [RabbitMQ.Client.ConnectionFactory].GetField("HostName")
    $hostnameProp.SetValue($connectionFactory, $HostName)

    $portProp = [RabbitMQ.Client.ConnectionFactory].GetField("Port")
    $portProp.SetValue($connectionFactory, $Port)

    $portProp = [RabbitMQ.Client.ConnectionFactory].GetProperty("UserName")
    $portProp.SetValue($connectionFactory, $UserName)

    $portProp = [RabbitMQ.Client.ConnectionFactory].GetProperty("Password")
    $portProp.SetValue($connectionFactory, $Password)

    Write-Verbose "Creating RabbitMQ connection: $UserName@$HostName : $Port"

    $createConnectionMethod = [RabbitMQ.Client.ConnectionFactory].GetMethod("CreateConnection", [Type[]]@())

    $connection = $createConnectionMethod.Invoke($connectionFactory, $null)
    $channel = $connection.CreateModel()

    return @{
        connection = $connection
        channel = $channel
    }
}