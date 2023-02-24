resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "random_pet" "table_name" {
  prefix = "rt"
}

resource "random_pet" "route_name" {
  count  = 2
  prefix = "udr"
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = "West Europe"
}

resource "azurerm_route_table" "rt" {
  name                = random_pet.table_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
