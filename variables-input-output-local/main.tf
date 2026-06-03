terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "4.72.0"
    }
  }
    backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstate12529"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    
  }
}

variable "environment" {
  type = string
  description = "Env for resource"
  default = "dev"
}

locals {
  comman_tags = {
  environment = "pre-prod"
  lab = "IT-sector"
  stage = "alpha"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "test-resources"
  location = "central india"
}

resource "azurerm_storage_account" "example" {
  name                     = "ironman1201"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = local.comman_tags.environment
  }
}

output "storage_account_name" {
  value = azurerm_storage_account.example.name
}