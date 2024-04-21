
#######################################################
# Create - resource group

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

#######################################################
#name of RG example - arg-dev-r1-poc-01
#location example - australiasoutheast

