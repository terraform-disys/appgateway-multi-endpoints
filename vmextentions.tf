#Resource 1: Virtual machine extention to run custom script 
resource "azurerm_virtual_machine_extension" "extension_vm1" {
  name                 = "vm1-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
    "fileUris": ["https://${azurerm_storage_account.rafi_app_storageacc.name}.blob.core.windows.net/data/IIS_Config_video.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_video.ps1"     
 }
SETTINGS


#   tags = {
#     environment = "Production"
#   }
}

resource "azurerm_virtual_machine_extension" "extension_vm2" {
  name = "vm2_extension"
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm2.id
  publisher = "Microsoft.compute"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "fileUris": ["https://${azurerm_storage_account.rafi_app_storageacc.name}.blob.core.windows.net/data/IIS_Config_image.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_image.ps1"
  }
  SETTINGS
}