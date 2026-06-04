resource "azurerm_resource_group" "example" {
  name     = "test-resources"
  location = var.region[2]
}
