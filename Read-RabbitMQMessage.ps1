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

        [Parameter()]
        [int] $Count = 1,

        [Switch]$AutoAck
    )
    Begin
    {
    }
    Process
    {        
    }
    End
    {
        function getMessages()
        {
            [System.Collections.ArrayList]$items = @()
            for ($i = 1; $i -le $Count; $i++)
            {
                $basicMessage = $Model.BasicGet($QueueName, $AutoAck)

                if (-not $basicMessage) { break }

                $message = [System.Text.Encoding]::Default.GetString($basicMessage.Body)
                $basicMessage | Add-Member Message $message

                if ($AutoAck) { Write-Verbose "Auto-Acknowledged message with tag $($basicMessage.DeliveryTag)." }

                $items.Add($basicMessage) | Out-Null
            }
            return $items
        }

        function getMessagesFromPrivateModel()
        {
            try {
                $Connection = New-RabbitMQConnection $HostName $Port $Credentials
                $Model = New-RabbitMQModel $Connection
                return getMessages
            }
            finally {
                Write-Verbose "Disposing RabbitMQ connection."
                $Model.Dispose()
                $Connection.Dispose()
            }
        }


        $messages = $null;
        switch ($PSCmdlet.ParameterSetName)
        {
            "implicit" { $messages = getMessages }
            "explicit" { $messages = getMessagesFromPrivateModel }
        }

        $messages
    }
}