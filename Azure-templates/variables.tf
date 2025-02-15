# NSG Framework

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "location" {
  description = "Azure region"
}

#NSG
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "location" {
  description = "Azure region"
}
#key vault
variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
}

variable "secrets" {
  description = "Map of secrets to store in Azure Key Vault"
  type        = map(string)
}
# Disk encryption

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "vm_name" {
  description = "Name of the Azure Virtual Machine"
}
