locals {
  name_prefix = "hashicorp-meetup"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}-rg"
  location = "${var.location}"

  tags = "${var.tags}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.12.0.0/16"]
  location            = "${var.location}"
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.name_prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${cidrsubnet("${element(azurerm_virtual_network.vnet.address_space, 0)}", 8, 12)}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-nic"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"

  ip_configuration {
    name                          = "${local.name_prefix}-private-ip"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address            = "${cidrhost(azurerm_subnet.subnet.address_prefix, 12)}"
    private_ip_address_allocation = "static"
    public_ip_address_id          = "${azurerm_public_ip.ip.id}"
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "${local.name_prefix}-ip"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${local.name_prefix}-vm"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${var.location}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_B1ms"

  os_profile {
    computer_name  = "${local.name_prefix}-azure-vm"
    admin_username = "ubuntu"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${file(var.public_key_path)}"
      path     = "/home/ubuntu/.ssh/authorized_keys"
    }
  }

  storage_os_disk {
    name          = "${local.name_prefix}-os-disk"
    create_option = "FromImage"
    disk_size_gb  = 32
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "remote-exec" {
    script = "${var.script_path}"

    connection {
      type           = "ssh"
      user           = "ubuntu"
      agent          = true
      agent_identity = "ubuntu"
    }
  }
}
