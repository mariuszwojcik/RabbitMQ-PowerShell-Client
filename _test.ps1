cls
Import-Module 'C:\Code\Custom Solution\GitHub\RabbitMQ-PowerShell-Client' -Force

#Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" -Port 32771 | Remove-RabbitMQMessage

if (-not $credentials) {
    $global:credentials = Get-Credential 'admin'
}

$connection = New-RabbitMQConnection -HostName mqc01 -Credential $global:credentials -Verbose
$model = New-RabbitMQModel $connection

$messages = Read-RabbitMQMessage "EasyNetQ_Default_Error_Queue" $model -Verbose -Count 10000 -PrefetchCount 1000


[System.Collections.ArrayList]$msgs = @()
foreach($rm in $messages)
{
    if ($rm)
    {
        $m = $rm.Message | ConvertFrom-Json

        $msgs.Add($rm) | Out-Null
    }
<#    
    if ($m.Exchange -eq "TravelRepublic.Bookings.Contracts.BookingEvent:TravelRepublic.Bookings.Contracts")
    {
        if ($m.Exception -notmatch "Violation of UNIQUE KEY constraint 'UN_UserAndTrpUtmId'")
        {
            $msgs.Add($m) | Out-Null
        }
    }
#>
}



$msgs | measure
#$msgs | Out-GridView

#$messages[0] | select *

$model.Dispose()
$connection.Dispose()



