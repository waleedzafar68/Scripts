
provider "azurerm" {  
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = "LabResourceGroup2"
  location = "eastus"
  tags = {
    "Created by" = "Waleed Zafar"
    "Description" = "Contain all lab resources"
  }
}

#Deploying Virtual Network
resource "azurerm_virtual_network" "labVnet" {
  name = "VTFLabVNet"
  location = "eastus"
  address_space = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.lab.name
  tags = {
    "Created by" = "Waleed Zafar"
    "Description" = "Contain all lab subnets and virtual machines"
  }
}

#Deploying Subnet DMZ
resource "azurerm_subnet" "subDMZ" {
  name = "DMZ"
  resource_group_name = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.labVnet.name
  address_prefixes = ["10.0.1.0/24"]
}

#Deploying Subnet DMZ
resource "azurerm_subnet" "subKali" {
  name = "KaliSN"
  resource_group_name = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.labVnet.name
  address_prefixes = ["10.1.0.0/24"]
}
#Deploying NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "VTFLabNSG"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_network_security_rule" "Rule80" {
  name                        = "Web80"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "Rule443" {
  name                        = "Web443"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

  resource "azurerm_network_security_rule" "RDP" {
  name                        = "RDP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#Attaching Subnet to NSG
resource "azurerm_subnet_network_security_group_association" "nsgDMZsn" {
  subnet_id                 = azurerm_subnet.subDMZ.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


#Deploying Public IP for Wordpress VM
resource "azurerm_public_ip" "wppubip" {
  name                = "dcPubIP"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  allocation_method   = "Dynamic"
  domain_name_label   = "vtfredteamdc"

  tags = {
    environment = "DC VM public IP"
  }
}

#Deploy NIC for VM Wordpress
# Create network interface
resource "azurerm_network_interface" "wpNIC" {
  name                = "dcNIC"
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

# Create Windows Server
resource "azurerm_windows_virtual_machine" "DomainControl" {
  name                  = "dc-vm"
  location              = azurerm_resource_group.lab.location
  resource_group_name   = azurerm_resource_group.lab.name
  size                  = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.wpNIC.id]
  
  computer_name  = "dc-vm"
  admin_username = "WaleedforVTF"
  admin_password = "WaleedforVTF#123"
  os_disk {
    name                 = "dc-vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  provision_vm_agent       = true
}


