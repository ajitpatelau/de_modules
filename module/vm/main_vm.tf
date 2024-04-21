
#######################################################
# Variables - Locals

locals {
  avs = toset([for k, v in var.vmList : v.availabilitySet])
  nicInfo = flatten([
    for k, v in var.vmList : [
      for nicName, value in v.nics : {
        vmName     = k
        nicName    = "${k}-${nicName}"
        subnetName = value
        enableAN   = replace(v.vmPublisher, "SQL", "") != v.vmPublisher ? true : false
      }
    ]
  ])
  vmSubnetIds = { for k, v in local.nicInfo : v.vmName => azurerm_network_interface.nic[v.nicName].id... }
  diskInfo = flatten([
    for k, v in var.vmList : [
      for dataDiskName, value in v.dd : {
        vmName        = k
        dataDiskName  = "${k}-dataDisk-${dataDiskName}"
        dataDiskType  = v.diskType
        dataDiskLabel = dataDiskName
        dataDiskSize  = value.size
        lun           = value.lun
      }
    ]
  ])
  dataDiskLabels       = { for k, v in local.diskInfo : v.vmName => v.dataDiskLabel... }
  dataDiskLabelsJoined = { for k, v in local.dataDiskLabels : k => "${join(",", v)}" }
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
# Query - existing subnet

resource "azurerm_subnet" "sbnt" {
  for_each             = toset([for k, v in local.nicInfo : v.subnetName])
  name                 = each.value
  resource_group_name  = azurerm_resource_group.arg.name
  virtual_network_name = azurerm_virtual_network.vnt.name
  address_prefixes     = ["10.0.1.0/24"]
}

#######################################################
# Create - availability set

resource "azurerm_availability_set" "avs" {
  depends_on = [
    azurerm_resource_group.arg
  ]

  for_each                     = local.avs
  name                         = each.value
  location                     = azurerm_resource_group.arg.location
  resource_group_name          = azurerm_resource_group.arg.name
  platform_update_domain_count = 5
  platform_fault_domain_count  = 2
  tags                         = local.tags
}

#######################################################
# Create - network interface

resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_resource_group.arg
  ]

  for_each                      = { for item in local.nicInfo : "${item.nicName}" => item }
  name                          = each.value.nicName
  location                      = azurerm_resource_group.arg.location
  resource_group_name           = azurerm_resource_group.arg.name
  enable_accelerated_networking = each.value.enableAN
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.sbnt[each.value.subnetName].id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

#######################################################
# Create - virtual machine

resource "azurerm_windows_virtual_machine" "vm" {
  depends_on = [
    azurerm_resource_group.arg,
    azurerm_availability_set.avs,
    azurerm_network_interface.nic
  ]

  for_each                 = var.vmList
  name                     = each.key
  resource_group_name      = azurerm_resource_group.arg.name
  location                 = azurerm_resource_group.arg.location
  size                     = each.value.vmSize
  admin_username           = "azVmAdministrator"
  admin_password           = azurerm_key_vault_secret.vmsecret.value
  network_interface_ids    = local.vmSubnetIds[each.key]
  availability_set_id      = azurerm_availability_set.avs[each.value.availabilitySet].id
  provision_vm_agent       = true
  enable_automatic_updates = false
  patch_mode               = "Manual"
  timezone                 = "AUS Eastern Standard Time"
  license_type             = "Windows_Server"
  boot_diagnostics {}
  os_disk {
    name                 = "${each.key}-os"
    caching              = "ReadWrite"
    storage_account_type = each.value.diskType
  }
  source_image_reference {
    publisher = each.value.vmPublisher
    offer     = each.value.vmOffer
    sku       = each.value.vmSku
    version   = each.value.vmVersion
  }
  identity {
    type = "SystemAssigned"
  }
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
    "UpdateGroup"           = "${var.environment[var.env]}-Standard"
  }
}

#######################################################
# Create - Managed Disks

resource "azurerm_managed_disk" "datadisk" {
  depends_on = [
    azurerm_resource_group.arg
  ]

  for_each             = { for item in local.diskInfo : "${item.dataDiskName}" => item }
  name                 = each.value.dataDiskName
  location             = azurerm_resource_group.arg.location
  resource_group_name  = azurerm_resource_group.arg.name
  storage_account_type = each.value.dataDiskType
  create_option        = "Empty"
  disk_size_gb         = each.value.dataDiskSize
  tags                 = local.tags
}

#######################################################
# Create - Managed Disks

resource "azurerm_virtual_machine_data_disk_attachment" "attachdatadisk" {
  depends_on = [
    azurerm_windows_virtual_machine.vm,
    azurerm_managed_disk.datadisk
  ]

  for_each           = { for item in local.diskInfo : "${item.dataDiskName}" => item }
  managed_disk_id    = azurerm_managed_disk.datadisk["${each.value.vmName}-dataDisk-${each.value.dataDiskLabel}"].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.value.vmName].id
  lun                = each.value.lun
  caching            = each.value.dataDiskLabel == "SQLData" ? "ReadOnly" : each.value.dataDiskLabel == "SQLLog" ? "None" : each.value.dataDiskLabel == "SQLTemp" ? "ReadOnly" : "ReadWrite"
}

#######################################################
# Create - Virtual Machine Extension - Domain Join

resource "azurerm_virtual_machine_extension" "domainjoin" {
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.attachdatadisk
  ]

  for_each             = var.vmList
  name                 = "JsonADDomainExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
  settings           = <<SETTINGS
    {
      "Name": "education.vic.gov.au",
      "OUPath": "${replace(each.value.vmPublisher, "SQL", "") != each.value.vmPublisher == true ? "OU=Database Servers,OU=" : "OU="}${var.env == "dev" ? "1_Development" : var.env == "tst" ? "2_Test" : var.env == "stg" ? "3_Staging" : "6_Production"},OU=Servers,DC=education,DC=vic,DC=gov,DC=au",
      "User": "${azurerm_key_vault_secret.domainjoinuser.value}",
      "Restart": "true",
      "Options": "3"
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${azurerm_key_vault_secret.domainjoinpassword.value}"
    }
  PROTECTED_SETTINGS
  tags               = local.tags
}

#######################################################
# Create - sql virtual machine (management)

resource "azurerm_mssql_virtual_machine" "sqlmgmt" {
  depends_on = [
    azurerm_virtual_machine_extension.domainjoin,
    azurerm_virtual_machine_data_disk_attachment.attachdatadisk
  ]

  for_each = {
    for k, v in var.vmList : k => v
    if(replace(v.vmPublisher, "SQL", "") != v.vmPublisher ? true : false)
  }
  virtual_machine_id               = azurerm_windows_virtual_machine.vm[each.key].id
  sql_license_type                 = "AHUB"
  r_services_enabled               = true
  sql_connectivity_port            = 1435
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = azurerm_key_vault_secret.vmsecret.value
  sql_connectivity_update_username = "sqllogin"
  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"

    # The storage_settings block supports the following:
    data_settings {
      default_file_path = "F:\\SQL\\Data\\"
      luns              = [each.value.dd["SQLData"].lun]
    }

    log_settings {
      default_file_path = "G:\\SQL\\Log\\"
      luns              = [each.value.dd["SQLLog"].lun]
    }

    temp_db_settings {
      default_file_path = "H:\\SQL\\Temp\\"
      luns              = [each.value.dd["SQLTemp"].lun]
    }
  }
  tags = local.tags
}

#######################################################
# Create - Virtual Machine Extension - Azure Dependency Agent

resource "azurerm_virtual_machine_extension" "dependencyagent" {
  depends_on = [
    azurerm_virtual_machine_extension.domainjoin,
    azurerm_mssql_virtual_machine.sqlmgmt
  ]

  for_each                   = var.vmList
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true
  tags                       = local.tags
}

#######################################################
# Create - Virtual Machine Extension - Microsoft Monitoring Agent

resource "azurerm_virtual_machine_extension" "mma" {
  depends_on = [
    azurerm_virtual_machine_extension.dependencyagent
  ]

  for_each                   = var.vmList
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.key].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "workspaceId":  "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
  tags                       = local.tags
}

#######################################################
# Create - Virtual Machine Extension - Custom Script

resource "azurerm_virtual_machine_extension" "customscript" {
  depends_on = [
    azurerm_virtual_machine_extension.mma
  ]

  for_each             = local.dataDiskLabelsJoined
  name                 = "CustomScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
    {
        "fileUris": ["https://stacrer1deploy01.blob.core.windows.net/deployscript/PostProvision.ps1"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ./PostProvision.ps1 -dataDiskLabelsJoined ${each.value}"
    }
  SETTINGS
  tags                 = local.tags
}

#######################################################
# Outputs
/*
output "nicIps" {
  value = zipmap(values(azurerm_network_interface.nic)[*].name, values(azurerm_network_interface.nic)[*].ip_configuration)
}
*/
#######################################################
