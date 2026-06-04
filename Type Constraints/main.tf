resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = [element(var.network_configuration,0)]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["${element(var.network_configuration,1)}/${element(var.network_configuration,2)}"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
  
}

resource "azurerm_public_ip" "example" {
  name = "example-public-ip"
  resource_group_name = azurerm_resource_group.example.name 
  location = azurerm_resource_group.example.location
  allocation_method = "Static"
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.vm_config.size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = var.disk_size  
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = var.vm_config.offer
    sku       = var.vm_config.sku
    version   = var.vm_config.version
  }
  tags = { 
    environment = var.resource_tags["environment"]
    project = var.resource_tags["project"]
    versions = var.resource_tags["version"]
   }
}