resource "azurerm_network_security_group" "app_nsg" {  //Here defined the network secrity group
  name                = "backend-nsg"  
  location            = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name

  
  security_rule {  //Here opened https port
    name                       = "HTTPS"  
    priority                   = 1000  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "443"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
  
  security_rule {   //Here opened remote desktop port
    name                       = "RDP"  
    priority                   = 110  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "3389"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  

}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  depends_on = [
    azurerm_network_security_group.app_nsg
  ]
}