# main.tf

provider "azurerm" {
  features = {}
}

module "nsg_framework" {
  source = "./modules/nsg_framework"

  resource_group_name = "example-rg"
  location            = "East US"

  nsgs = {
    nsg1 = {
      name = "nsg1"
      security_rules = [
        {
          name                       = "allow-ssh"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Deny"  # Change to Deny
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          source_port_range          = "*"
          destination_address_prefix = "*"
          destination_port_range     = "22"
        },
        {
          name                       = "allow-rdp"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Deny"  # Change to Deny
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          source_port_range          = "*"
          destination_address_prefix = "*"
          destination_port_range     = "3389"
        },
        # Add additional rules as needed
      ]
    },
    # Add additional NSGs as needed
  }
}

provider "azurerm" {
  features = {}
}

module "key_vault_integration" {
  source = "./modules/key_vault_integration"

  resource_group_name = "example-rg"
  location            = "East US"
  key_vault_name      = "example-key-vault"
  secrets             = {
    database_password = "superSecretPassword123"
    api_key           = "apiKeyValue"
  }
}

provider "azurerm" {
  features = {}
}

module "disk_encryption" {
  source = "./modules/disk_encryption"

  resource_group_name = "example-rg"
  vm_name             = "example-vm"
}

#Secure Subnet
provider "azurerm" {
  features = {}
}

module "secure_subnets" {
  source = "./modules/secure_subnets"

  resource_group_name = "example-rg"
  location            = "East US"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

# SSL for databases 

provider "azurerm" {
  features = {}
}

module "ssl_databases" {
  source = "./modules/ssl_databases"

  resource_group_name = "example-rg"
  nsg_name            = "example-nsg"
}
