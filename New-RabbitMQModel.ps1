<#
.Synopsis
   Create new RabbitMQ model.

.DESCRIPTION
   New-RabbitMQModel creates new RabbitMQ model.

.EXAMPLE
   New-RabbitMQModel $connection

   Creates new RabbitMQ model.
   
#>
function New-RabbitMQModel
{
    [CmdletBinding()]
    Param
    (
        # RabbitMQ server host
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [RabbitMQ.Client.IConnection] $Connection
    )
    Begin
    {
    }
    Process
    {        
    }
    End
    {
        $model = $connection.CreateModel()
        $model
    }
}