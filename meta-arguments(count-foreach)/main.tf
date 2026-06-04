# resource "azurerm_storage_account" "example" {
#   count = length(var.storage_acc_name)
#   name                     = var.storage_acc_name[count.index]
#   resource_group_name      = azurerm_resource_group.example.name
#   location                 = azurerm_resource_group.example.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = {
#     environment = "staging"
#   }
# }

# for each not work with list because list contains dublicates
resource "azurerm_storage_account" "example" {
 for_each = var.storage_acc_name
  name                     = each.key
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
