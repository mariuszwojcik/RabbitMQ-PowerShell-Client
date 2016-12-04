<#
.Synopsis
   Reads message from RabbitMQ queue.

.DESCRIPTION
   Read-RabbitMQMessage

.EXAMPLE
   Read-RabbitMQMessage Test

   Read 1 messages from queue named Test. 

.EXAMPLE
   Read-RabbitMQMessage Test RabbitServer 32771

   Read 1 messages from queue named Test from host called RabbitServer using port 32771. 

.EXAMPLE
   Read-RabbitMQMessage Test -AutoAck

   Read 1 messages with auto-acknowledgement from queue named Test.
   Auto-acknowledgment removes automatically message from the queue.
   

.EXAMPLE
   Read-RabbitMQMessage Test -AsJson

   Read 1 messages from queue named Test and returns message's body decoded from JSON.
#>
function Read-RabbitMQMessage
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string] $QueueName,

        [Parameter(ParameterSetName="implicit", Mandatory=$true, ValueFromPipeline=$true, Position=1)]
        [RabbitMQ.Client.IModel] $Model,



        # RabbitMQ server host
        [Parameter(ParameterSetName="explicit", Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)]
        [string] $HostName = "localhost",

        # RabbitMQ server port
        [Parameter(ParameterSetName="explicit", Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)]
        [int] $Port = 5672,

        [Parameter(ParameterSetName="explicit", Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3)]
        [PSCredential] $Credentials,

        [Switch]$AutoAck,
        [Switch]$AsJson
    )
    Begin
    {
    }
    Process
    {        
    }
    End
    {
        function getMessage()
        {
            $basicMessage = $Model.BasicGet($QueueName, $AutoAck)
            $message = [System.Text.Encoding]::Default.GetString($basicMessage.Body)
            $basicMessage | Add-Member Message $message

            if ($AutoAck) { Write-Verbose "Auto-Acknowledged message with tag $($basicMessage.DeliveryTag)." }

            return $basicMessage
        }

        function getMessageFromPrivateModel()
        {
            try {
                $Connection = New-RabbitMQConnection $HostName $Port $Credentials
                $Model = New-RabbitMQModel $Connection
                return getMessage
            }
            finally {
                Write-Verbose "Disposing RabbitMQ connection."
                $Model.Dispose()
                $Connection.Dispose()
            }
        }


        $basicMessage = $null;
        switch ($PSCmdlet.ParameterSetName)
        {
            "implicit" { $basicMessage = getMessage }
            "explicit" { $basicMessage = getMessageFromPrivateModel }
        }

        

        if ($AsJson) {
            $json = $basicMessage.Message | ConvertFrom-Json
            $json

        } else {
            sendItemsToOutput $basicMessage "Message"
        }
    }
}