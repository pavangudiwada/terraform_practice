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

resource "azurerm_resource_group" "windowsvm-rg" {
  name     = "windows_vm_group"
  location = "eastus2"
}

resource "azurerm_virtual_network" "windowsvm-vnet" {
  name                = "windowsvm_vnet"
  location            = azurerm_resource_group.windowsvm-rg.location
  resource_group_name = azurerm_resource_group.windowsvm-rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.windowsvm-rg.name
  virtual_network_name = azurerm_virtual_network.windowsvm-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.windowsvm-vnet
  ]
}

resource "azurerm_network_interface" "windowsvm-interface" {
  name                = "windowsvm_interface"
 location            = azurerm_resource_group.windowsvm-rg.location
  resource_group_name = azurerm_resource_group.windowsvm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id =  azurerm_public_ip.public-ip.id
  }

  depends_on = [
    azurerm_virtual_network.windowsvm-vnet,
    azurerm_public_ip.public-ip,
  ]
}

resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = azurerm_resource_group.windowsvm-rg.name
  location            = azurerm_resource_group.windowsvm-rg.location
  size                = "Standard_F2"
  admin_username      = "demousr"
  admin_password      = "Azure@123"
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.windowsvm-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.windowsvm-interface,
     azurerm_availability_set.app_set
  ]
}

resource "azurerm_public_ip" "public-ip" {
  name = "windowsvm_publicip"
  resource_group_name = azurerm_resource_group.windowsvm-rg.name
  location = azurerm_resource_group.windowsvm-rg.location
  allocation_method = "Static"
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "data-disk"
  resource_group_name = azurerm_resource_group.windowsvm-rg.name
  location = azurerm_resource_group.windowsvm-rg.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16
}
resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.app_vm.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on = [
    azurerm_windows_virtual_machine.app_vm,
    azurerm_managed_disk.data_disk
  ]
}

resource "azurerm_availability_set" "app_set" {
  name                = "app-set"
  resource_group_name = azurerm_resource_group.windowsvm-rg.name
  location = azurerm_resource_group.windowsvm-rg.location
  platform_fault_domain_count = 3
  platform_update_domain_count = 3  
  depends_on = [
    azurerm_resource_group.windowsvm-rg,
  ]
}

