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
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage-sa" {
  name                     = var.sa_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier              = var.account_tire
  account_replication_type = var.replication_type
  allow_blob_public_access = var.blobpublic_access   
}