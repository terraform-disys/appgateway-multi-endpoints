#Resource 1: Public IP
resource "azurerm_public_ip" "rafi-pip" {
  name                = "vm-pip"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location
  allocation_method   = "Dynamic" #public ip will not show up until attached to some resource

  tags = {
    environment = "Production"
  }
}

#Resource-2: Network security group for appgw
#Rules for NSG Rules
## Locals Block for Security Rules
locals {
  ag_inbound_ports_map = {
    "100" : "80", # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "110" : "443",
    "130" : "65200-65535"
  } 
}
resource "azurerm_network_security_group" "agsubnet-nsg" {
  name                = "${var.appgw-name}-subnet-nsg"
  location            = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name

  security_rule {
    name                       = "security-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*" #allows all protocols
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Resource-3: Appgw network security group and appgw subnet association
resource "azurerm_subnet_network_security_group_association" "ag_subnet_nsg_assoc" {
    subnet_id = azurerm_network_security_group.agsubnet-nsg.id
    network_security_group_id = azurerm_network_security_group.agsubnet-nsg.id
  
}

#Resource-4: Application gateway
resource "azurerm_application_gateway" "rafi-ag" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  # ssl_certificate {
  #   name = "ag-ssl-cert"
  #   data = ""
  # }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agsubnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # Frontend Port  - HTTP Port 443
  frontend_port {
    name = local.frontend_port_name_https
    port = 443    
  }  
  
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.rafi-pip.id
  }

   backend_address_pool{      
      name  = "videopool"
      ip_addresses = [
      "${azurerm_network_interface.nic_vm1.ip_addresses}"
      ]
    }

    backend_address_pool {
      name  = "imagepool"
      ip_addresses = [
      "${azurerm_network_interface.nic_vm2.ip_addresses}"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

 ssl_certificate {
    name = "my-cert-1"
    password = "hello@123"
    data = filebase64("./disys-cert.pfx")
  }

  #https listener
  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_https
    protocol                       = "Https"    
    ssl_certificate_name           = "my-cert-1"    
  }

  # HTTPS Routing Rule - Port 443
  request_routing_rule {
    name = local.request_routing_rule_name_https
    rule_type = "PathBasedRouting"
    http_listener_name = local.listener_name_https
    url_path_map_name = "RoutingPath"
  }
#   request_routing_rule {
#     name                       = local.request_routing_rule_name_https
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name_https
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name 
#   }
  
  url_path_map {
    name = "RoutingPath"
    default_backend_address_pool_name = "videopool"
    default_backend_http_settings_name = local.backend_http_settings.name
    
    path_rule {
      name                          = "VideoRoutingRule"
      backend_address_pool_name     = "videopool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/videos/*",
      ]
    }

    path_rule {
      name                          = "ImageRoutingRule"
      backend_address_pool_name     = "imagepool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/images/*",
      ]
    }
  }
}


# resource "azurerm_application_gateway" "rafi-ag" {
#   name                = "appgateway"
#   resource_group_name = azurerm_resource_group.rafi-rg.name
#   location            = azurerm_resource_group.rafi-rg.location

#   sku {
#     name     = "Standard_Small"
#     tier     = "Standard"
#     capacity = 2
#   }

#   # ssl_certificate {
#   #   name = "ag-ssl-cert"
#   #   data = ""
#   # }

#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.frontend.id
#   }

#   frontend_port {
#     name = local.frontend_port_name
#     port = 80
#   }

#   # Frontend Port  - HTTP Port 443
#   frontend_port {
#     name = local.frontend_port_name_https
#     port = 443    
#   }  
  
#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.rafi-pip.id
#   }

#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = "Disabled"
#     path                  = "/path1/"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#  ssl_certificate {
#     name = "my-cert-1"
#     password = "hello@123"
#     data = filebase64("./disys-cert.pfx")
#   }

#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }

#  # Redirect Config for HTTP to HTTPS Redirect  
#   redirect_configuration {
#     name = local.redirect_configuration_name
#     redirect_type = "Permanent"
#     target_listener_name = local.listener_name_https
#     include_path = true
#     include_query_string = true
#   }  

#   #https listener
#   http_listener {
#     name                           = local.listener_name_https
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name_https
#     protocol                       = "Https"    
#     ssl_certificate_name           = "my-cert-1"    
#   }

#   # HTTPS Routing Rule - Port 443
#   request_routing_rule {
#     name                       = local.request_routing_rule_name_https
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name_https
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name 
#   }
  
# }



# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   network_interface_id    = azurerm_network_interface.
#   ip_configuration_name   = "nic-ipconfig"
#   backend_address_pool_id = one(azurerm_application_gateway.rafi-ag.backend_address_pool).id
# }