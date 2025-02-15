# modules/key_vault_integration/key_vault_integration.tf

provider "azurerm" {
  features = {}
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "location" {
  description = "Azure region"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
}

variable "secrets" {
  description = "Map of secrets to store in Azure Key Vault"
  type        = map(string)
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true

  sku {
    family = "A"
    name   = "standard"
  }

  tenant_id     = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled = true
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.key_vault.id
}

data "azurerm_client_config" "current" {}

output "key_vault_id" {
  value = azurerm_key_vault.key_vault.id
}
