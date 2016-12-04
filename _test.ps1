cls
Import-Module 'C:\Code\RabbitMQ-PowerShell-Client' -Force

#Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" -Port 32771 | Remove-RabbitMQMessage



$connection = New-RabbitMQConnection -Port 32771
$model = New-RabbitMQModel $connection

$i = Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" $model -Verbose -Count 2 | select Message


$i | measure

$model.Dispose()
$connection.Dispose()

