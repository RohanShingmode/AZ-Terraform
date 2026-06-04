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
    virtual_machine {
      delete_os_disk_on_deletion = var.delete_os_disk
    }
  }
}