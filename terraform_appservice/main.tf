terraform {
 required_providers {
   azurerm={
       source = "hashicorp/azurerm"
       version = "=2.96.0"
   }
 }
}

provider "azurerm" {
  features{}
}


resource "azurerm_resource_group" "svcrg" {
  name = "mysvcrg"
  location = "eastus"
}

resource "azurerm_app_service_plan" "mysvcplan" {
    name = "myserviceplan"
    location = azurerm_resource_group.svcrg.location
    resource_group_name = azurerm_resource_group.svcrg.name

    sku {
      tier = "Basic"
      size = "B1"
    }

}

resource "azurerm_app_service" "mysvc" {
    name = "myservicerandom221221"
    location = azurerm_resource_group.svcrg.location
    resource_group_name = azurerm_resource_group.svcrg.name
    app_service_plan_id = azurerm_app_service_plan.mysvcplan.id

    site_config {
      python_version = "3.4"
      scm_type = "LocalGit"
    }

    connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
  
}
