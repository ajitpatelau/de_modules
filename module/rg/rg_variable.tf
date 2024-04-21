
/*
common-var.tf

Terraform file to define common variables

# Define the variable definition i.e. type and the default value
# Variable values can be found in terraform.tfvarsxx file

# Terraform CLI defines the following optional arguments for variable declarations:

# default - A default value which then makes the variable optional.
# type - This argument specifies what value types are accepted for the variable.
# description - This specifies the input variable's documentation.
# validation - A block to define validation rules, usually in addition to type constraints.
# sensitive - Limits Terraform UI output when the variable is used in configuration.
*/

#######################################################
# Variables - Common
variable "resource_group_name" {
    type          = any
    description   = "name of resource group"
    #default       = "arg-${var.env}-${var.location[var.deploy.location].code}-${var.refName}-${var.instance}"
}

variable "deploy" {
  type        = map(any)
  description = "Location to be reployed"
  
  }


variable "location" {
  type        = map(any)
  description = "Location information for the resources"
  default = {
    "mel" = {
      code   = "r1",
      region = "Australia Southeast"
    }
    "syd" = {
      code   = "r2",
      region = "Australia East"
    }
  }
}

variable "env" {
  type        = string
  description = "Environment code for the resource"
  
}

variable "refName" {
  type        = string
  description = "Reference name for the application/Service"
  

}

variable "instance" {
  type        = string
  description = "Instance number for the resource"
  
}
/*
variable "azurePrivateDNS" {
  type        = map(any)
  description = "Azure Private DNS mapping"
  default = {
    "sites"     = "privatelink.azurewebsites.net"
    "blob"      = "privatelink.blob.core.windows.net"
    "sqlServer" = "privatelink.database.windows.net"
    "file"      = "privatelink.file.core.windows.net"
    "queue"     = "privatelink.queue.core.windows.net"
    "table"     = "privatelink.table.core.windows.net"
    "vault"     = "privatelink.vaultcore.azure.net"
    "web"       = "privatelink.web.core.windows.net"
  }
}
*/
#######################################################
# Variables - Common Tags

variable "environment" {
  type        = map(any)
  description = "Environment Names"
  default = {
    "poc" = "POC"
    "dev" = "Development"
    "tst" = "Testing"
    "stg" = "Staging"
    "prd" = "Production"
    "cre" = "Production"
  }
}

variable "costCentre" {
  type        = string
  description = "Cost Centre Code/Number"
}

variable "service" {
  type        = string
  description = "Service/Application Name"
}

variable "serviceDescription" {
  type        = string
  description = "Service Description"
}

variable "serviceOwner" {
  type        = string
  description = "Service Owner Name"
}

variable "serviceOwnerGroup" {
  type        = string
  description = "Service Owner Business Group Name"
}

variable "technicalContact" {
  type        = string
  description = "Technical Contact Name"
}

variable "technicalContactGroup" {
  type        = string
  description = "Technical Contact Group Name"
}




#######################################################
