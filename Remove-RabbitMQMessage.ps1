<#
.Synopsis
   Removes message from RabbitMQ queue.

.DESCRIPTION
   Remove-RabbitMQMessage

.EXAMPLE
   Remove-RabbitMQMessage Test

#>
function Remove-RabbitMQMessage
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [RabbitMQ.Client.BasicGetResult] $Message,

        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [RabbitMQ.Client.IModel] $Model
    )
    Begin
    {
    }
    Process
    {        
    }
    End
    {
        Write-Verbose "Acknowledging message with tag $($Message.DeliveryTag)"

        $Message

        $Model

        #$Model.BasicaCK($Message.DeliveryTag, $false)
    }
}