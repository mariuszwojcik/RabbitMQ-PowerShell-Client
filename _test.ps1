cls
Import-Module 'C:\Code\RabbitMQ-PowerShell-Client' -Force

Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" -Port 32771 -AsJson -Verbose

<#

$c1 = New-RabbitMQConnection -Port 32771 -Verbose
$m1 = New-RabbitMQModel $c1

Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" $m1 -AsJson -AutoAck

$m1.Dispose()
$c1.Dispose()

#>
