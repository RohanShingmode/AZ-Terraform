# for each not work with list because list contains dublicates
resource "azurerm_storage_account" "example" {
 for_each = var.storage_acc_name
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

lifecycle {
  # prevent_destroy = true
  create_before_destroy = true
  ignore_changes = [ tags ]
} 
  tags = {
    environment = "staging"
  }
}
