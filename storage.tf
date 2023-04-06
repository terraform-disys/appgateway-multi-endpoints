#Resource-9: Storage account to create blobs that contain html files to be hosted
resource "azurerm_storage_account" "rafi_app_storageacc" {
  name                = "appstorageacc"
  resource_group_name = azurerm_resource_group.rafi-rg.name

  location                 = azurerm_resource_group.rafi-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  account_kind = "BlobStorage"

  # network_rules {
  #   default_action             = "Deny"
  #   ip_rules                   = ["100.0.0.1"]
  #   virtual_network_subnet_ids = [azurerm_subnet.example.id]
  # }
}

#Resource-10: storage container
resource "azurerm_storage_container" "storage_container_data" {
  #required attributes
  name = "data"
  storage_account_name = azurerm_storage_account.rafi_app_storageacc.name
  container_access_type = "blob"

  #optional
  depends_on = [
    azurerm_storage_account.rafi_app_storageacc
  ]
}

#Resource-11: blob container for image app & videos app
resource "azurerm_storage_blob" "image_blob" {
  #required
  name                   = "image_pool.ps1"
  storage_account_name   = "appstore4577687"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config_image.ps1"

  depends_on=[azurerm_storage_container.storage_container_data]
}

resource "azurerm_storage_blob" "video_blob" {
  #required
  name                   = "vidoes_pool.ps1"
  storage_account_name   = "appstore4577687"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config_video.ps1"

  depends_on=[azurerm_storage_container.storage_container_data]
}

