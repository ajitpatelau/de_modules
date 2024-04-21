
#######################################################
# Azure Provider source and version being used

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

# Store Terraform state in an Azure storage account and use custom configuration for the Terraform state remote backend
# Note: Azure storage account should be created first
/*terraform {
  backend "azurerm" {
    #resource_group_name  = "arg-cre-r1-terraform-01"
    #storage_account_name = "stacrer1deploy01"
    #container_name       = "terraformstatefiles" # Use "temp" container for tests
    #key                  = "<resource_group_name>.tfstate"
  }
}*/

# Configure the Microsoft Azure Provider # OUT BY AJIT
provider "azurerm" {
    features {}
}


# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = "1db5b1e9-e507-4ff2-822b-3957510873b2"
}

provider "azurerm" {
  features {}

  alias           = "CoreServices"
  subscription_id = "33026753-f02d-4d4e-9133-e9ef846aeab5"
  tenant_id = "1db5b1e9-e507-4ff2-822b-3957510873b2"
}

#######################################################
# Query - Current Client Config

data "azurerm_client_config" "current" {}

#######################################################
# Query - Log Analytics Workspace

resource "azurerm_log_analytics_workspace" "law" {
  provider = azurerm.CoreServices

  name                = "law-cre-r1-common-01"
  location            =  var.location[var.deploy.location].region 
  resource_group_name = azurerm_resource_group.arg.name
}

#######################################################
# Query - DNS Zones

resource "azurerm_private_dns_zone" "dnszone" {
  provider = azurerm.CoreServices

  for_each            = var.azurePrivateDNS
  name                = each.value
  resource_group_name = azurerm_resource_group.arg.name
}

#######################################################
# Query - existing key vault

resource "azurerm_key_vault" "akv" {
  provider = azurerm.CoreServices

  name                = "detestapril2024"
  resource_group_name = azurerm_resource_group.arg.name
  sku_name            = "standard"
  location            = var.location[var.deploy.location].region 
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete"
    ]
    secret_permissions = [
      "Get",
      "List",
      "Delete",
      "Set",
      "Restore"
    ]
  }
}


#######################################################
# Query - existing key vault secret

resource "azurerm_key_vault_secret" "vmsecret" {
  provider = azurerm.CoreServices

  name         = "vmAdminPassword"
  value        = "Bluebird@134"
  key_vault_id = azurerm_key_vault.akv.id
}

resource "azurerm_key_vault_secret" "domainjoinuser" {
  provider = azurerm.CoreServices

  name         = "domainJoinUser"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.akv.id
}

resource "azurerm_key_vault_secret" "domainjoinpassword" {
  provider = azurerm.CoreServices

  name         = "domainJoinUserPassword"
  value        = "Bluebird@134"
  key_vault_id = azurerm_key_vault.akv.id
}

#######################################################
# Query - existing VNET resource group
/*
resource "azurerm_resource_group" "vntarg" {
  name = "arg-${var.env}-network-01"
  #name                = "arg-${var.env}-${var.location[each.key].code}-network-01"
}
*/
# Query - existing VNET
resource "azurerm_virtual_network" "vnt" {
  name                = "vnt-${var.env}-${var.location[var.deploy.location].code}-${var.env == "cre" ? "02" : "01"}"
  location            =  var.location[var.deploy.location].region 
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.arg.name
}

#######################################################
# Outputs

#######################################################
