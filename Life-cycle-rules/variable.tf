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

# variable "storage_acc_name" {
#   type = set(string)
#   description = "multiple storage account"
#   default = [ "spiderman12012003", "azurelearnning894" ]
# }

variable "storage_acc_name" {
  type = map(string)
  description = "multiple storage account"
  default = {
    "account1" = "spiderman12012002"
    "account2" = "azurelearnning893" 
  }
}
