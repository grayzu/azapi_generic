resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "random_pet" "aks_name" {
  prefix    = "aks"
  separator = ""
}

resource "random_pet" "uai_name" {
  prefix    = "uai"
  separator = ""
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = random_pet.aks_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = random_pet.aks_name.id

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_user_assigned_identity" "uai" {
  name                = random_pet.uai_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

data "azurerm_resource_group" "aks_mc_rg" {
  name = "MC_${azurerm_resource_group.rg.name}_${azurerm_kubernetes_cluster.aks.name}_${azurerm_resource_group.rg.location}"
}
