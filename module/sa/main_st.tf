
#######################################################
# Create - Storage Account
resource "azurerm_storage_account" "sta" {
  for_each                 = var.staList
  name                     = each.key
  resource_group_name      = azurerm_resource_group.arg.name
  location                 = azurerm_resource_group.arg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  blob_properties {
    versioning_enabled = true
    container_delete_retention_policy {
      days = 31
    }
    delete_retention_policy {
      days = 31
    }
  }
  network_rules {
    default_action = each.value.denyPublicAccess == true ? "Deny" : "Allow"
  }
  tags = {
    "Environment"           = var.environment[var.env]
    "CostCentre"            = var.costCentre
    "Service"               = var.service
    "ServiceDescription"    = var.serviceDescription
    "ServiceOwner"          = var.serviceOwner
    "ServiceOwnerGroup"     = var.serviceOwnerGroup
    "TechnicalContact"      = var.technicalContact
    "TechnicalContactGroup" = var.technicalContactGroup
    "DeploymentType"        = "Terraform"
  }
}

#######################################################
# Query - existing subnet

resource "azurerm_subnet" "pepstasbnt" {
  for_each             = toset([for k, v in var.staList : v.subnetName])
  name                 = each.value
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.vnt.name
  address_prefixes     = ["10.0.1.0/24"]
}

#######################################################
# Create - Private Endpoint

resource "azurerm_private_endpoint" "pepsta" {
  depends_on = [
    azurerm_resource_group.arg,
    azurerm_storage_account.sta
  ]

  for_each = {
    for k, v in var.staList : k => v
    if v.createPrivateEndpoint == true ? true : false
  }
  name                = "pep-${azurerm_storage_account.sta[each.key].name}"
  resource_group_name      = azurerm_resource_group.arg.name
  location                 = azurerm_resource_group.arg.location
  subnet_id           = azurerm_subnet.pepstasbnt[each.value.subnetName].id
  private_service_connection {
    name                           = "pep-${azurerm_storage_account.sta[each.key].name}-psc"
    private_connection_resource_id = azurerm_storage_account.sta[each.key].id
    subresource_names              = [each.value.resourceToConnect]
    is_manual_connection           = false
  }
  tags = {
    "Environment"           = var.environment[var.env]
    "CostCentre"            = var.costCentre
    "Service"               = var.service
    "ServiceDescription"    = var.serviceDescription
    "ServiceOwner"          = var.serviceOwner
    "ServiceOwnerGroup"     = var.serviceOwnerGroup
    "TechnicalContact"      = var.technicalContact
    "TechnicalContactGroup" = var.technicalContactGroup
    "DeploymentType"        = "Terraform"
  }
}

#######################################################
# Create - DNS A Record

resource "azurerm_private_dns_a_record" "dnspepsta" {
  depends_on = [
    azurerm_resource_group.arg,
    azurerm_private_endpoint.pepsta
  ]
  provider = azurerm.CoreServices

  for_each = {
    for k, v in var.staList : k => v
    if v.createPrivateEndpoint == true ? true : false
  }
  name                = each.key
  zone_name           = azurerm_private_dns_zone.dnszone[each.value.resourceToConnect].name
  resource_group_name = azurerm_resource_group.arg.name
  ttl                 = 10
  records             = azurerm_private_endpoint.pepsta[each.key].custom_dns_configs[0].ip_addresses
}


#######################################################
