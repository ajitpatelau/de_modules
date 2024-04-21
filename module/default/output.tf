/*output "output_aazurerm_client_config.current" {
  description = "The id of the azurerm_log_analytics_workspace"
  value       = azurerm_client_config.current.id
}*/
output "output_azurerm_log_analytics_workspace_law" {
  description = "The id of the azurerm_log_analytics_workspace"
  value       = azurerm_log_analytics_workspace.law.id
}
output "output_azurerm_private_dns_zone_dnszone" {
  value = {
    for key, zone in azurerm_private_dns_zone.dnszone :
    key => zone.name
  }
}
output "output_azurerm_key_vault_akv" {
  description = "The Name of the azurerm_key_vault"
  value       = azurerm_key_vault.akv.id
}
output "output_azurerm_key_vault_secret_vmsecret" {
  description = "The Name of the azurerm_key_vault_secret_vmsecret"
  value       = azurerm_key_vault_secret.vmsecret.id
}
output "output_azurerm_key_vault_secret_domainjoinuser" {
  description = "The location of the azurerm_key_vault_secret.domainjoinuser"
  value       = azurerm_key_vault_secret.domainjoinuser.id
}
output "output_azurerm_key_vault_secret_domainjoinpassword" {
  description = "The address space of the newly created vNet"
  value       = azurerm_key_vault_secret.domainjoinpassword.id
}
output "output_azurerm_virtual_network_vnt" {
  description = "The address space of the azurerm_virtual_network.vnt"
  value       = azurerm_virtual_network.vnt.name
}
output "output_azurerm_resource_group_arg" {
  description = "The address space of resource group"
  value       = azurerm_resource_group.arg.name
}

output "output_azurerm_resource_group_arg_location" {
  description = "The address space of the location"
  value       = azurerm_resource_group.arg.location
}



