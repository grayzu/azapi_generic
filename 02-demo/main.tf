resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "random_pet" "sa_name" {
  prefix    = "sa"
  separator = ""
}

resource "random_pet" "plan_name" {
  prefix = "plan"
}

resource "random_pet" "func_name" {
  prefix = "func"
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = "canadacentral"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = random_pet.sa_name.id
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "service_app" {
  name                = random_pet.plan_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                = random_pet.func_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name = azurerm_storage_account.storage_account.name
  service_plan_id      = azurerm_service_plan.service_app.id

  site_config {}

  lifecycle {
    // appsettings is already supported in azurerm, this example demostrates how to use azapi_resource_action to update the settings
    ignore_changes = [app_settings]
  }
}
