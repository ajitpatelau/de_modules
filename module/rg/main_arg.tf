


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

# Configure the Microsoft Azure Provider
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
}

#######################################################

# Create - resource group

resource "azurerm_resource_group" "arg" {
  name     = var.resource_group_name
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


#######################################################

