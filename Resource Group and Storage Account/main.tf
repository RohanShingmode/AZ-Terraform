terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "4.72.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "example" {
  name     = "test-resources"
  location = "central india"
}

resource "azurerm_storage_account" "example" {
  name                     = "ironman1201"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location  #implicit dependency and depends_on - explicit
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "prod"
  }
}


#terrafom plan
#terrafom plan | grep "will be created"
#terraform validate
#terraform apply
#terraform apply --auto-approve
#terraform destroy