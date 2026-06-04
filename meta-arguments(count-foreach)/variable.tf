variable "environment" {
  type = string
  default = "staging"
}

variable "region" {
  type = string
  default = "Central India"
}
# variable "storage_acc_name" {
#   type = string
#   default = "spiderman12012002"
# }

variable "storage_acc_name" {
  type = set(string)
  description = "multiple storage account"
  default = [ "spiderman12012002", "azurelearnning890" ]
}