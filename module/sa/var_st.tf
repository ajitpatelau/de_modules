
#######################################################
# Variables - Storage Account

variable "staList" {
  type        = map(any)
  description = "Storage Account List and related information"
  default = {
    "stadevr1abcd01" = {
      "createPrivateEndpoint" = true
      "resourceToConnect"     = "blob" # pick one from the variable 'azurePrivateDNS'
      "subnetName"            = "Data"
      "denyPublicAccess"      = true
    }
  }
}

#######################################################
/*variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
*/
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
  default     = "dev"
}

variable "refName" {
  type        = string
  description = "Reference name for the application/Service"
  default     = "poc"
}

variable "instance" {
  type        = string
  description = "Instance number for the resource"
  default     = "01"
}

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
  default     = "11-3552-86105-355108-0000"
}

variable "service" {
  type        = string
  description = "Service/Application Name"
  default     = "<SERVICE>"
}

variable "serviceDescription" {
  type        = string
  description = "Service Description"
  default     = "Azure resources for the SERVICE"
}

variable "serviceOwner" {
  type        = string
  description = "Service Owner Name"
  default     = "Matt Stokeld"
}

variable "serviceOwnerGroup" {
  type        = string
  description = "Service Owner Business Group Name"
  default     = "IMTD - Infrastructure Engineering"
}

variable "technicalContact" {
  type        = string
  description = "Technical Contact Name"
  default     = "Ravneet Chalana"
}

variable "technicalContactGroup" {
  type        = string
  description = "Technical Contact Group Name"
  default     = "IMTD - Infrastructure Engineering"
}




#######################################################
