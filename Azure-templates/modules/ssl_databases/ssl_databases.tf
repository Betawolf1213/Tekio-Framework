# modules/ssl_for_databases/ssl_for_databases.tf

provider "azurerm" {
  features = {}
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.resource_group_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "ssl_rule" {
  name                        = "ssl-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"  # Assuming MySQL database, change if necessary
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Allow SSL traffic for databases"
  network_security_group_name = azurerm_network_security_group.nsg.name
}
