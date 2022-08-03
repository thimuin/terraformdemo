data "azurerm_resource_group" "thimu" {
  name     = "winvmdemo"
}


resource "azurerm_virtual_network" "thimu" {
  name                = "thimu-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.thimu.location
  resource_group_name = data.azurerm_resource_group.thimu.name
}

resource "azurerm_subnet" "thimu" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.thimu.name
  virtual_network_name = azurerm_virtual_network.thimu.name
  address_prefixes     = ["10.0.2.0/24"]
}
/* #add public IP syntax here additionally  */

resource "azurerm_public_ip" "thimu" {
  name                = "lunixpublicip"
  resource_group_name = data.azurerm_resource_group.thimu.name
  location            = data.azurerm_resource_group.thimu.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}



resource "azurerm_network_interface" "thimu" {
  name                = "thimu-nic"
  location            = data.azurerm_resource_group.thimu.location
  resource_group_name = data.azurerm_resource_group.thimu.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.thimu.id
    private_ip_address_allocation = "Dynamic"

    /* add public IP address*/
    public_ip_address_id = azurerm_public_ip.thimu.id
  }
}

resource "azurerm_linux_virtual_machine" "thimu" {
  name                = "linuxmachine"
  resource_group_name = data.azurerm_resource_group.thimu.name
  location            = data.azurerm_resource_group.thimu.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "TerraForm$2022"
  /* Diff between VM in Windows & linux is disable pwd settings */
  disable_password_authentication = false
    network_interface_ids = [
    azurerm_network_interface.thimu.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

output "mysize" {
    value = azurerm_linux_virtual_machine.thimu.size
}


output "myip" {
    value = azurerm_public_ip.thimu.ip_address
}

output "vmname" {
    value = azurerm_linux_virtual_machine.thimu.name
}

output "macaddress" {
    value = azurerm_network_interface.thimu.mac_address
}