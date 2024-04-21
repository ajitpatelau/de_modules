
# Create - virtual network
resource "azurerm_virtual_network" "vnt" {
  /*depends_on = [
    azurerm_resource_group.arg
  ]*/

  name                = "vnt-${var.env}-${var.location[var.deploy.location].code}-01"
  location            = var.location[var.deploy.location].region
  resource_group_name = module.resource_group.output_azurerm_resource_group_arg

  address_space = [
    var.vntCIDR.vnt.cidr
  ]

  dns_servers = [
    "10.9.62.4", "10.9.62.5", "10.9.174.4", "10.9.174.5"
  ]

  tags = {
    "Environment"           = var.environment[var.env]
    "CostCentre"            = var.costCentre
    "Service"               = var.service
    "ServiceDescription"    = var.serviceDescription
    "ServiceOwner"          = var.serviceOwner
    "ServiceOwnerGroup"     = var.serviceOwnerGroup
    "TechnicalContact"      = var.technicalContact
    "TechnicalContactGroup" = var.technicalContactGroup
    "ManagedBy"             = "Terraform"
  }
}

#######################################################
# Create Subnets
resource "azurerm_subnet" "sbnt" {
  depends_on = [
    azurerm_resource_group.arg,
    azurerm_virtual_network.vnt
  ]

  for_each             = var.vntCIDR.sbnt
  name                 = each.key
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.vnt.name
  address_prefixes = [
    each.value
  ]
  #enforce_private_link_endpoint_network_policies = true
}

#######################################################
# Create VNET Peering
/*
resource "azurerm_virtual_network_peering" "vnetpeering" {
  depends_on = [
    azurerm_resource_group.arg,
    azurerm_virtual_network.vnt
  ]

  for_each                  = var.peernetwork
  name                      = "${azurerm_virtual_network.vnt.name}-to-${each.value.name}"
  resource_group_name       = azurerm_resource_group.arg.name
  virtual_network_name      = azurerm_virtual_network.vnt.name
  remote_virtual_network_id = data.azurerm_virtual_network.crevnt[each.key].id
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  allow_virtual_network_access = true
  use_remote_gateways = false
}
*/
#######################################################
