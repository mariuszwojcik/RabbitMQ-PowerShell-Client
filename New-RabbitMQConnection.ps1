<#
.Synopsis
   Create new connection to RabbitMQ server.

.DESCRIPTION
   New-RabbitMQConnection creates new connection to RabbitMQ server.

.EXAMPLE
   New-RabbitMQConnection

   Creates new connection to local RabbitMQ server using default credentials.
   
#>
function New-RabbitMQConnection
{
    [CmdletBinding()]
    Param
    (
        # RabbitMQ server host
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string] $HostName = "localhost",

        # RabbitMQ server port
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)]
        [int] $Port = 5672,

        # RabbitMQ credentials
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)]
        [PSCredential] $Credential,

        # RabbitMQ Virtual Host
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3)]
        [string] $VirtualHost = "/"
    )
    Begin
    {
        $modulePath = (Get-Module RabbitMQ-PowerShell-Client).ModuleBase
        [System.Reflection.Assembly]::LoadFile("$modulePath\RabbitMQ.Client.dll") | Out-Null

        if ($Credential) {
            $UserName = $Credential.UserName
            $Password = $Credential.GetNetworkCredential().Password
        } else {
            $UserName = "guest"
            $Password = "guest"
        }
    }
    Process
    {        
    }
    End
    {
        $connectionFactory = New-Object RabbitMQ.Client.ConnectionFactory

        $hostnameProp = [RabbitMQ.Client.ConnectionFactory].GetField("HostName")
        $hostnameProp.SetValue($connectionFactory, $HostName)

        $portProp = [RabbitMQ.Client.ConnectionFactory].GetField("Port")
        $portProp.SetValue($connectionFactory, $Port)

        $portProp = [RabbitMQ.Client.ConnectionFactory].GetProperty("UserName")
        $portProp.SetValue($connectionFactory, $UserName)

        $portProp = [RabbitMQ.Client.ConnectionFactory].GetProperty("Password")
        $portProp.SetValue($connectionFactory, $Password)

        $virtualHostProp = [RabbitMQ.Client.ConnectionFactory].GetProperty("VirtualHost")
        $virtualHostProp.SetValue($connectionFactory, $VirtualHost)

        Write-Verbose "Creating RabbitMQ connection: $UserName@$HostName : $Port virtualHost: $VirtualHost"
        
        $createConnectionMethod = [RabbitMQ.Client.ConnectionFactory].GetMethod("CreateConnection", [Type[]]@())

        $connection = $createConnectionMethod.Invoke($connectionFactory, $null)

        $connection
    }
}