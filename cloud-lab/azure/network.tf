resource "azurerm_resource_group" "lab_rg" {
  name     = "lab-devops-rg"
  location = var.location
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "lab-devops-vnet"
  location            = azurerm_resource_group.lab_rg.location
  resource_group_name = azurerm_resource_group.lab_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "lab-devops-subnet"
  resource_group_name  = azurerm_resource_group.lab_rg.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
