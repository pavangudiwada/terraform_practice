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

resource "azurerm_resource_group" "vm_rg" {
  name     = "vm_resource"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vm_vn" {
  name                = "vm_virtualnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name = "vm-subnet"
  # location            = azurerm_resource_group.vm_rg.location
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.vm_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public-ip" {
  name = "linuxvm_publicip"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location = azurerm_resource_group.vm_rg.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "vm_nif" {
  name                = "vm_networkinterface"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm_vm" {
  name                = "vm_virtualmachine"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = "Standard_F2"
  computer_name       = "linuxmachine"
  admin_username      = "linux"
  admin_password        = "Whatcrazy@2022"
  network_interface_ids           = [azurerm_network_interface.vm_nif.id, ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


