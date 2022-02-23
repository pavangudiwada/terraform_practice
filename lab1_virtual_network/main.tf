terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.96.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-lab"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "subnet1" {
  name = "vnet1_subnet1"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
depends_on = [
  azurerm_virtual_network.vnet
]
}

resource "azurerm_subnet" "subnet2" {
  name = "vnet1_subnet2"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.2.0/24"]

  depends_on = [
  azurerm_virtual_network.vnet
]
}

resource "azurerm_public_ip" "vm1_ip" {
  name = "vm1_ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method = "Static"
}
resource "azurerm_public_ip" "vm2_ip" {
  name = "vm2_ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "nif1" {
  name                = "vm1_nif"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm1_ip.id
  }
}


resource "azurerm_network_interface" "nif2" {
  name                = "vm2_nif"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm2_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vnet1-vm-mgmt1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = "Standard_F2"
  computer_name       = "linuxmachine"
  admin_username      = "linux"
  admin_password        = "Whatcrazy@2022" #Change the password 
  network_interface_ids           = [azurerm_network_interface.nif1.id, ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm_virtualmachine"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  size                = "Standard_F2"
  computer_name       = "linuxmachine"
  admin_username      = "linux"
  admin_password        = "Whatcrazy@2022" #Change the password
  network_interface_ids           = [azurerm_network_interface.nif2.id, ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}