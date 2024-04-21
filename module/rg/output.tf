output "output_azurerm_resource_group_arg" {
  description = "The address space of resource group"
  value       = azurerm_resource_group.arg.name
}

output "output_azurerm_resource_group_arg_location" {
  description = "The address space of the location"
  value       = azurerm_resource_group.arg.location
}