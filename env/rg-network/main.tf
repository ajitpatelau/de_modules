provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "../../module/rg"
  resource_group_name   = var.resource_group_name
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
  }#version = "1.1.0"
  #context = module.this.context

  #name     = "example-rg"
  #location = "West Europe"
}

module "vnet" {
  source    = "../../module/network"
  #version = "2.6.0"
  #resource_group_name  = module.resource_group.output_azurerm_resource_group_arg
  #address_space       = ["10.0.0.0/16"]
  #subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  #subnet_names        = ["web", "app"]

  depends_on = [module.resource_group]
}

