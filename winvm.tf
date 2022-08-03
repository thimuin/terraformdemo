provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmdemo" {
  name     = "winvmdemo"
  location = "West Europe"
}



resource "azurerm_virtual_network" "vmdemo" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmdemo.location
  resource_group_name = azurerm_resource_group.vmdemo.name
}

resource "azurerm_subnet" "vmdemo" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vmdemo.name
  virtual_network_name = azurerm_virtual_network.vmdemo.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmdemo" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.vmdemo.name
  location            = azurerm_resource_group.vmdemo.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "vmdemo" {
  name                = "example-nic"
  location            = azurerm_resource_group.vmdemo.location
  resource_group_name = azurerm_resource_group.vmdemo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vmdemo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vmdemo.id

  }
}

resource "azurerm_windows_virtual_machine" "vmdemo" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.vmdemo.name
  location            = azurerm_resource_group.vmdemo.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vmdemo.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}