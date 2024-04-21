#######################################################
# Resource Type Specific Variables - Virtual Network
variable "vntCIDR" {
  type        = map(any)
  description = "Network VNET CIDR Range for all regions"
  default = {
    "vnt" = {
      "cidr" = "10.9.112.0/20"
    }
    "sbnt" = {
      "Outside-LB-FW1" = "10.9.112.0/28"
      "Outside-LB-FW2" = "10.9.112.16/28"
      "Outside-LB-FW3" = "10.9.112.32/28"
      "Outside-LB-FW4" = "10.9.112.48/28"
      "Outside-LB-FW5" = "10.9.112.64/28"
      "Inside-LB"      = "10.9.113.0/24"
      "Management"     = "10.9.114.0/24"
      #"Del-PaaS-serverFarms" = "10.9.115.0/29"
      "Web"  = "10.9.122.0/24"
      "App"  = "10.9.124.0/24"
      "Data" = "10.9.126.0/24"
    }
  }
}

variable "peernetwork" {
  type        = map(any)
  description = "List of CORE VNETS to which the this VNET will be Peered"
  default = {
    "core01" = {
      name    = "vnt-cre-r1-01"
      argName = "arg-cre-network-01"
    }
    "core02" = {
      name    = "vnt-cre-r1-02"
      argName = "arg-cre-network-01"
    }
  }
}

#######################################################