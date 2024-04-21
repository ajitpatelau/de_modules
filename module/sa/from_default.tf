resource "azurerm_resource_group" "arg" {
  name     = "arg-${var.env}-${var.location[var.deploy.location].code}-${var.refName}-${var.instance}"
  location = var.location[var.deploy.location].region 

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

resource "azurerm_virtual_network" "vnt" {
  name                = "vnt-${var.env}-${var.location[var.deploy.location].code}-${var.env == "cre" ? "02" : "01"}"
  location            =  var.location[var.deploy.location].region 
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.arg.name
}

# Query - DNS Zones

resource "azurerm_private_dns_zone" "dnszone" {
  provider = azurerm.CoreServices

  for_each            = var.azurePrivateDNS
  name                = each.value
  resource_group_name = azurerm_resource_group.arg.name
}