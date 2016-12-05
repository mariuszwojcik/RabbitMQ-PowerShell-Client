<#
.Synopsis
   Reads message from RabbitMQ queue.

.DESCRIPTION
   Measure-RabbitMQQueue

.EXAMPLE
   Measure-RabbitMQQueue Test

   Gets number of messages and number of consumers for Test queue. 

.EXAMPLE
   Measure-RabbitMQQueue "EasyNetQ_Default_Error_Queue" RabbitMQServer -Credentials $(Get-Credential)

   Gets number of messages and number of consumers for EasyNetQ_Default_Error_Queue queue on server RabbitMQServer. 


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