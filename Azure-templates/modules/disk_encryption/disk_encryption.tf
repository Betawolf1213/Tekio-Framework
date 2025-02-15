# modules/disk_encryption/disk_encryption.tf

provider "azurerm" {
  features = {}
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
}

variable "vm_name" {
  description = "Name of the Azure Virtual Machine"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.resource_group_name
  resource_group_name   = var.resource_group_name
  ...

  os_profile {
    ...

    linux_config {
      disable_password_authentication = false
    }
  }

  storage_image_reference {
    ...
  }

  storage_os_disk {
    ...
  }
}

resource "azurerm_key_vault" "disk_encryption_kv" {
  name                        = "disk-encryption-kv"
  location                    = var.resource_group_name
  resource_group_name         = var.resource_group_name
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

resource "azurerm_key_vault_key" "disk_encryption_key" {
  name         = "disk-encryption-key"
  key_vault_id = azurerm_key_vault.disk_encryption_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

resource "azurerm_virtual_machine_extension" "disk_encryption_extension" {
  name                 = "enableEncryption"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = {
    script = <<SETTINGS
      #!/bin/bash
      mkdir -p /mnt/azure_bek_disk
      mkfs -t ext4 /dev/sdc
      mount /dev/sdc /mnt/azure_bek_disk
      echo "${azurerm_key_vault_key.disk_encryption_key.secret_value}" > /mnt/azure_bek_disk/diskencryptionkey.pem
      curl -o /mnt/azure_bek_disk/azure_disk_encryption_enable.sh https://raw.githubusercontent.com/Azure/azure-linux-extensions/master/Dsc/Scripts/enable-encryption-prereq.sh
      chmod +x /mnt/azure_bek_disk/azure_disk_encryption_enable.sh
      /mnt/azure_bek_disk/azure_disk_encryption_enable.sh
      umount /mnt/azure_bek_disk
      SETTINGS
  }

  settings = <<SETTINGS
    {
        "script": "echo hello"
    }
    SETTINGS
}
