
# Create a resource group
resource "azurerm_resource_group" "rafi-rg" {
  name     = "rafi-resources"
  location = "Central India"
}

# Resource-2 : VNet
resource "azurerm_virtual_network" "rafi-vnet" {
  name                = "rafi-network"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location
  address_space       = ["10.0.0.0/16"]
}

#Resource-3: Subnet for appgw
resource "azurerm_subnet" "agsubnet" {
  name                 = "${var.appgw-name}-subnet"
  resource_group_name  = azurerm_resource_group.rafi-rg.name
  virtual_network_name = azurerm_virtual_network.rafi-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
#Resource-4: Subnet for backend pool
resource "azurerm_subnet" "backend" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rafi-rg.name
  virtual_network_name = azurerm_virtual_network.rafi-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Resource-5: NIC card for VM1 (Image pool target)
resource "azurerm_network_interface" "nic_vm1" {
  name = "app-interface1"
  location = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"

  }

  depends_on = [
    azurerm_virtual_network.rafi-vnet,
    azurerm_subnet.backend
  ]
}

#Resource-6: NIC card for VM2 (Videos pool target)
resource "azurerm_network_interface" "nic_vm2" {
  name = "app-interface2"
  location = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.rafi-vnet,
    azurerm_subnet.backend
  ]
}

#Resource-7: VM1: Windows datacenter for videos pool
#windows vm
resource "azurerm_windows_virtual_machine" "app_vm1" {
  name                = "app-vm1-videos"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureadmin"
  admin_password      = "Terraform@123" 
  network_interface_ids = [
    azurerm_network_interface.nic_vm1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#Resource-8: VM2: Windows datacenter for images pool
#windows vm
resource "azurerm_windows_virtual_machine" "app_vm2" {
  name                = "app-vm2-images"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureadmin"
  admin_password      = "Terraform@123" 
  network_interface_ids = [
    azurerm_network_interface.nic_vm2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}

