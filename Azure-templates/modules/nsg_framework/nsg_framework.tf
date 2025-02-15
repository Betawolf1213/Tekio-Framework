# modules/nsg_framework/nsg_framework.tf

provider "azurerm" {
  features = {}
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "location" {
  description = "Azure region"
}

variable "nsgs" {
  description = "Map of NSG configurations"
  type        = map(object({
    name           = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_address_prefix      = string
      source_port_range          = string
      destination_address_prefix = string
      destination_port_range     = string
    }))
  }))
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.nsgs

  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "nsg_rule" {
  for_each = var.nsgs

  security_group_name = azurerm_network_security_group.nsg[each.key].name
  priority            = 1001
  direction           = "Inbound"
  access              = "Deny"
  protocol            = "*"
  source_address_prefix = "*"
  source_port_range   = "*"
  destination_address_prefix = "*"
  destination_port_range     = "*"
}

resource "azurerm_network_security_rule" "nsg_custom_rule" {
  for_each = var.nsgs

  security_group_name = azurerm_network_security_group.nsg[each.key].name
  dynamic "rule" {
    for_each = each.value.security_rules

    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_address_prefix      = rule.value.source_address_prefix
      source_port_range          = rule.value.source_port_range
      destination_address_prefix = rule.value.destination_address_prefix
      destination_port_range     = rule.value.destination_port_range
    }
  }

  dynamic "deny_ftp_rule" {
    for_each = [for r in each.value.security_rules : r if r.protocol == "Tcp" && r.destination_port_range == "20-21"]

    content {
      rule {
        name                       = "deny-ftp"
        priority                   = each.value.priority + 1
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "20-21"
      }
    }
  }
}
