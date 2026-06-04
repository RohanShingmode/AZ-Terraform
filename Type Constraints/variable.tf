variable "environment" {
  type = string
  description = "Env for resource"
  default = "stag"
}

variable "disk_size" {
  type = number
  description = "OS disk size"
  default = 30
  
}

variable "delete_os_disk" {
  type = bool
  description = "delete OS disk false"
  default = true
}

variable "region" {
  type = list(string)
  description = "region selection"
  default = [ "West US", "East US", "Central India" ]
}

variable "resource_tags" {
  type = map(string)
  description = "resource tags map"
  default = {
    "project" = "test"
    "environment" = "dev"
    "version" = "pre-test"
  }
}

variable "network_configuration" {
  type = tuple([ string, string, number ])
  description = "network configuration settings"
  default = ["10.0.0.0/16","10.0.2.0",24]
}

variable "azure_regions" {
  type        = set(string)
  description = "A list of unique Azure regions to deploy resources."
  default     = ["eastus", "westus", "centralus"]
}

variable "vm_config" {
  type = object({
    size = string
    version = string
    sku = string
    offer = string
  })
  description = "virtual machine configrations"
  default = {
    size = "Standard_B1s"
    version = "latest"
    sku = "22_04-lts"
    offer = "0001-com-ubuntu-server-jammy"
  }
}
