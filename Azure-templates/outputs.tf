# outputs.tf

output "nsg_ids" {
  value = azurerm_network_security_group.nsg[*].id
}


output "key_vault_id" {
  value = module.key_vault_integration.key_vault_id
}
