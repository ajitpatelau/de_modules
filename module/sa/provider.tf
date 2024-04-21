/*
provider "azurerm" {
  features {}

  alias           = "CoreServices"
  subscription_id = "33026753-f02d-4d4e-9133-e9ef846aeab5"
  var = {
      source  = "hashicorp/var"
      version = "2.2.0"  # Specify the version you need
  }
}

*/

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

#Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

/*
# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = "1db5b1e9-e507-4ff2-822b-3957510873b2"
}
*/
provider "azurerm" {
  features {}

  alias           = "CoreServices"
  subscription_id = "33026753-f02d-4d4e-9133-e9ef846aeab5"
}
