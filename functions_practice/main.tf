terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.96.0"
    }

    random = {
      source = "hashicorp/random"
    }

  }
}

provider "azurerm" {
  features {}
}

provider "random" {
  special = false
  upper   = false
  number  = false
  length  = 6

}

resource "azurerm_resource_group" "vm_rg" {
  for_each = var.environment
  name     = "${var.business_unit}-${each.key}-${var.resource_group_name}"
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "vm_vn" {
  for_each            = var.environment
  name                = "${var.business_unit}-${each.key}-${var.virtual_network_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm_rg[each.key].location
  resource_group_name = azurerm_resource_group.vm_rg[each.key].name
}

resource "azurerm_subnet" "vm_subnet" {
  for_each = var.environment
  name     = "${var.business_unit}-${each.key}-${var.virtual_network_name}-subnet"
  # location            = azurerm_resource_group.vm_rg.location
  resource_group_name  = azurerm_resource_group.vm_rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vm_vn[each.key].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  for_each = var.environment

  name                = "${var.business_unit}-${each.key}-publicip"
  location            = azurerm_resource_group.vm_rg[each.key].location
  resource_group_name = azurerm_resource_group.vm_rg[each.key].name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_nic" {
  for_each = var.environment

  name                = "${var.business_unit}-${each.key}-${var.virtual_network_name}-mynic"
  location            = azurerm_resource_group.vm_rg[each.key].location
  resource_group_name = azurerm_resource_group.vm_rg[each.key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm_vm" {
  for_each = var.environment

  name                            = "${each.key}-vm"
  location                        = azurerm_resource_group.vm_rg[each.key].location
  resource_group_name             = azurerm_resource_group.vm_rg[each.key].name
  size                            = "Standard_F2"
  computer_name                   = "${each.key}-linux"
  admin_username                  = "linux"
  admin_password                  = "Whatcrazy@2022"
  network_interface_ids           = [azurerm_network_interface.vm_nic[each.key].id, ]
  disable_password_authentication = false

  os_disk {
    name = "osdisk${each.key}"
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


