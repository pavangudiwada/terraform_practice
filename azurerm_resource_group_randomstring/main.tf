terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }

    random = {
        source = "hashicorp/random"
        version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "name" {
  length = 20
  special = true
  override_special = "-"
}

resource "azurerm_resource_group" "newgroup" {
  name     = random_string.name.result
  location = var.location
}