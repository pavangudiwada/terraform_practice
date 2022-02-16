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


resource "azurerm_resource_group" "vnet_group" {
  name     = "vnet_resource"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet_group"
  location            = azurerm_resource_group.vnet_group.location
  resource_group_name = azurerm_resource_group.vnet_group.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "test"
  }
}