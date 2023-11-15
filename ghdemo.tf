variable "DOCKER_REGISTRY_SERVER_USERNAME" {  
  type = string  
}  
  
variable "DOCKER_REGISTRY_SERVER_PASSWORD" {  
  type = string  
  sensitive = true  
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}
provider "azurerm" {  
  features {}  
}  
  
data "azurerm_resource_group" "existing" {  
  name = "lawa-shared-rg"  
}  
  
data "azurerm_container_registry" "existing" {  
  name                = "lawaacr"  
  resource_group_name = data.azurerm_resource_group.existing.name  
}  
  
resource "azurerm_app_service_plan" "example" {  
  name                = "lawa_app_service_plan"  
  location            = data.azurerm_resource_group.existing.location  
  resource_group_name = data.azurerm_resource_group.existing.name  
  
  sku {  
    tier = "Standard"  
    size = "S1"  
  }  

  kind     = "Linux"
  reserved = true
}
  
resource "azurerm_app_service" "example" {  
  name                = "lawaapp"  
  location            = data.azurerm_resource_group.existing.location  
  resource_group_name = data.azurerm_resource_group.existing.name  
  app_service_plan_id = azurerm_app_service_plan.example.id  
  
  site_config {  
    linux_fx_version = "DOCKER|${data.azurerm_container_registry.existing.login_server}/lawa:latest"  
  }  
  
  app_settings = {  
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${data.azurerm_container_registry.existing.login_server}"  
    "DOCKER_REGISTRY_SERVER_USERNAME" = data.azurerm_container_registry.existing.admin_username  
    "DOCKER_REGISTRY_SERVER_PASSWORD" = data.azurerm_container_registry.existing.admin_password  
  }  
}  
