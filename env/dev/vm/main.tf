
provider "azurerm" {
  features {}
}


# Define other resources using input variables as needed

module "vm" {
  source = "../../../module/vm"
  costCentre            = "11-3521-86105-351914-0000"
  service               = "Auth Store"
  serviceDescription    = "Auth Store Test resources"
  serviceOwner          = "Matt Stokeld"
  serviceOwnerGroup     = "IMTD - Infrastructure Engineering"
  technicalContact      = "Anup Pokhrel"
  technicalContactGroup = "IMTD - Infrastructure Engineering"
  instance              = "01"
  env                   = "dev"
  refName               = "demo"
  deploy = {
    location = "mel"
  }
  
}

module "default" {
  source = "../../../module/default"
  
}