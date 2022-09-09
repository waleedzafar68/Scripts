#Deploying Public IP for Wordpress VM
resource "azurerm_public_ip" "wppubip" {
  name                = "WPPubIP"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  allocation_method   = "Dynamic"
  domain_name_label   = "vtfredteam"

  tags = {
    environment = "Wordpress VM public IP"
  }
}

#Deploy NIC for VM Wordpress
# Create network interface
resource "azurerm_network_interface" "wpNIC" {
  name                = "wpNIC"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "wpNICconfig"
    subnet_id                     = azurerm_subnet.subDMZ.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wppubip.id
  }
  tags ={
    "Description" = "NIC to be attached to Vulnerable Wordpress VM"
  }
}


#Create Wordpress VM
# Create virtual machine
resource "azurerm_linux_virtual_machine" "VTFWPvm" {
  name                  = "VTFWordpressVM"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  network_interface_ids = [azurerm_network_interface.wpNIC.id]
  size                  = "Standard_B1s"
  allow_extension_operations = true

  os_disk {
    name                 = "wpOSDsk1"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    offer                 = "0001-com-ubuntu-server-focal"
    publisher             = "Canonical"
    sku                   = "20_04-lts-gen2"
    version               = "latest"
  }

  computer_name                   = "VTFWPVM"
  admin_username                  = "vtfuser1"
  disable_password_authentication = false
  admin_password = "VTFWaleed@231100"

}

#Running Script to initialize website on Port 80
resource "azurerm_virtual_machine_extension" "scriptWP2" {
  name                 = "WordPressInitScript2"
  virtual_machine_id   = azurerm_linux_virtual_machine.VTFWPvm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "script": "IyEgL3Vzci9iaW4vYmFzaApjZCAvCmVjaG8gImNsb25pbmcgZ2l0IgpnaXQgY2xvbmUgImh0dHBzOi8vZ2l0aHViLmNvbS93YWxlZWR6YWZhcjY4L3Z1bG5lcmFibGV3cC5naXQiCmVjaG8gIkNoYW5naW5nIERpcmVjdG9yeSIKY2QgdnVsbmVyYWJsZXdwCnNlZCAtaSAtZSAncy9cciQvLycgaW5zdGFsbC5zaCAjd2FzIGEgcHJvYmxlbSB3aXRoIGNhcnJpYWdlIHJldHVybgpiYXNoIGluc3RhbGwuc2gg"
    }
SETTINGS
}
