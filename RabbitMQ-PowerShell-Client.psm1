# Aliases
New-Alias -Name readMessage -value Read-RabbitMQMessage -Description "Reads message from RabbitMQ queue."

Export-ModuleMember -Alias * 

# Modules
Export-ModuleMember -Function New-RabbitMQConnection
Export-ModuleMember -Function New-RabbitMQModel
Export-ModuleMember -Function Read-RabbitMQMessage