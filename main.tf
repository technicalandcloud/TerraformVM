#Create RG
resource "azurerm_resource_group" "rg" {
  location = "North Europe"
  name     = "ThankYou108"
}

# Create VNet
resource "azurerm_virtual_network" "VNet" {
  name                = "Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet
resource "azurerm_subnet" "Subnet" {
  name                 = "Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create Bastion Subnet
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#Create IP Public of Bastion
resource "azurerm_public_ip" "BastionPublic"{
  name                = "MyIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
#Create Bastion
resource "azurerm_bastion_host" "BastionVM" {
  name                = "MyBastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.BastionPublic.id
  }
}

#Create NSG

resource "azurerm_network_security_group" "NSG" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#Associeate NSG of Subnet
resource "azurerm_subnet_network_security_group_association" "nsg-assosiation" {
subnet_id                 = azurerm_subnet.Subnet.id
network_security_group_id = azurerm_network_security_group.NSG.id
}

# Create NIC
resource "azurerm_network_interface" "nic_name" {
    count = var.nic
  name                = "${var.nic_name}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
#Generate random Password
resource "random_password" "password" {
  count = var.randomPassword
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
data "azurerm_client_config" "current" {}
#Création d'un KeyVault
resource "azurerm_key_vault" "keyvault" {
  name         = "keyvaultterraformtest"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Purge",
      "Delete"
    ]
  }
}
#Store Random Password in Keyvault
resource "azurerm_key_vault_secret" "passwordadmin" {
  count = var.secret
  name         = "passwordadmin-${count.index}"
  key_vault_id = azurerm_key_vault.keyvault.id
  value        = random_password.password[count.index].result

}

# Create Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.vm_count  
  name                  = "${var.vm_name}-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_name[count.index].id,]
  size                  = "Standard_B2s"
  admin_username  = "nicolas"
  admin_password =  random_password.password[count.index].result

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}
