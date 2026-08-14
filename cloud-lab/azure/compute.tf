locals {
  instances = {
    "swarm-mgr" = {
      name       = "swarm-mgr"
      private_ip = "10.0.1.10"
      vm_size    = "Standard_B2s"
    }
    "swarm-wkr-1" = {
      name       = "swarm-wkr-1"
      private_ip = "10.0.1.11"
      vm_size    = "Standard_B1s"
    }
    "swarm-wkr-2" = {
      name       = "swarm-wkr-2"
      private_ip = "10.0.1.12"
      vm_size    = "Standard_B1s"
    }
  }
}

resource "azurerm_public_ip" "lab_pip" {
  for_each            = local.instances
  name                = "${each.value.name}-pip"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "lab_nic" {
  for_each            = local.instances
  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
    public_ip_address_id          = azurerm_public_ip.lab_pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "swarm_nodes" {
  for_each            = local.instances
  name                = each.value.name
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name
  size                = each.value.vm_size
  admin_username      = "labadmin"

  network_interface_ids = [
    azurerm_network_interface.lab_nic[each.key].id
  ]

  admin_ssh_key {
    username   = "labadmin"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
