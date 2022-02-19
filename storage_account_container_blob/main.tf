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

resource "azurerm_resource_group" "storage-rg" {
  name     = "storage_resource_group"
  location = "eastus2"
}

resource "azurerm_storage_account" "storage-sa" {
  name                     = "storageaccount21288726"
  resource_group_name      = azurerm_resource_group.storage-rg.name
  location                 = azurerm_resource_group.storage-rg.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true       
}

resource "azurerm_storage_container" "storage-container" {
  name                 = "storagecontainer3455"
  storage_account_name = azurerm_storage_account.storage-sa.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "storage-blob" {
  name                   = "storage_blob_file"
  storage_account_name   = azurerm_storage_account.storage-sa.name
  storage_container_name = azurerm_storage_container.storage-container.name
  type                   = "Block"
  source                 = "morse.txt"
}