<#
.Synopsis
   Reads message from RabbitMQ queue.

.DESCRIPTION
   Measure-RabbitMQQueue

.EXAMPLE
   Measure-RabbitMQQueue Test

   Read 1 messages from queue named Test. 

.EXAMPLE
   Read-RabbitMQMessage Test RabbitServer 32771

   Read 1 messages from queue named Test from host called RabbitServer using port 32771. 

.EXAMPLE
   Read-RabbitMQMessage Test -AutoAck

   Read 1 messages with auto-acknowledgement from queue named Test.
   Auto-acknowledgment removes automatically message from the queue.

#>
function Measure-RabbitMQQueue
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
        [ValidateRange(0, 65535)]
        [int] $Port = 5672,

        [Parameter(ParameterSetName="explicit", Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=3)]
        [PSCredential] $Credentials,

        [Parameter(ParameterSetName="explicit", Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [string] $VirtualHost = "/"
    )
    Begin
    {
Write-Verbose $PSCmdlet.ParameterSetName
    }
    Process
    {        
    }
    End
    {
        function getQueueSize()
        {
            try {
                return $model.QueueDeclarePassive($QueueName)    
            }
            catch [RabbitMQ.Client.Exceptions.OperationInterruptedException] {
                if ($_.Exception.Message -match "text=""NOT_FOUND")
                {
                    Write-Warning "Queue $QueueName doesn't exist. Virtual host: $VirtualHost"
                } else {
                    throw
                }
            }
            
        }

        function getQueueSizeFromPrivateModel()
        {
            try {
                $Connection = New-RabbitMQConnection $HostName $Port $Credentials $VirtualHost
                $Model = New-RabbitMQModel $Connection
                return getQueueSize
            }
            finally {
                Write-Verbose "Disposing RabbitMQ connection."
                $Model.Dispose()
                $Connection.Dispose()
            }
        }


        $queue = $null;
        switch ($PSCmdlet.ParameterSetName)
        {
            "implicit" { $queue = getQueueSize }
            "explicit" { $queue = getQueueSizeFromPrivateModel }
        }

        $queue
    }
}