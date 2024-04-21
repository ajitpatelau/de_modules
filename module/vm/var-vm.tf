
#######################################################
# Variables - Virtual Machine

variable "vmList" {
  type        = map(any)
  description = "VM List and related information"
  default = {
    "testvm2022" = {
      "availabilitySet" = "avs-dev-r1-testvm-01"
      "vmSize"          = "Standard_B2ms" # Standard_B2ms, Standard_D3_v2
      "diskType"        = "Standard_LRS"
      "nics" = {
        "nic" = "App"
      }
      "dd" = {
        "Data" = {
          name = "Data" # SQLData, SQLLog, SQLTemp for sql vm in this sequence
          size = 32
          lun  = 0
        }
      }
      "vmPublisher" = "MicrosoftWindowsServer" # MicrosoftWindowsServer, MicrosoftSQLServer
      "vmOffer"     = "WindowsServer"          # WindowsServer, Windows10, SQL2019-WS2019
      "vmSku"       = "2022-Datacenter"        # 2019-Datacenter, Enterprise
      "vmVersion"   = "latest"
    }
  }
}

# Non-Sql Box (copy the paramters and replace in the variable map
/*
If sql box, use the values below

"vmPublisher" = "MicrosoftSQLServer"
"vmOffer"     = "SQL2019-WS2019"
"vmSku"       = "Enterprise"

*/

#######################################################
# Non-Sql Box (copy the paramters and replace in the variable map
/*

"vmPublisher" = "MicrosoftWindowsServer"
"vmOffer"     = "WindowsServer"
"vmSku"       = "2019-Datacenter"

*/

#######################################################
