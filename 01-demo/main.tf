resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "random_pet" "acr_name" {
  prefix    = "acr"
  separator = ""
}

resource "random_pet" "acrtask_name" {
  prefix = "acrtask"
  length = 1
}

resource "random_pet" "ca_env" {
  prefix = "caenv"
}

resource "random_pet" "ca" {
  prefix = "ca"
}

data "azurerm_key_vault" "kv" {
  name                = "kv-mc808080"
  resource_group_name = "common_infra"
}

data "azurerm_key_vault_secret" "gh_pat" {
  name         = "mcg-gh-pat"
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "example"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_registry" "acr" {
  name                = random_pet.acr_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_container_registry_task" "acr_task" {
  name                  = random_pet.acrtask_name.id
  container_registry_id = azurerm_container_registry.acr.id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = "https://github.com/Azure-Samples/aci-helloworld.git#master"
    context_access_token = data.azurerm_key_vault_secret.gh_pat.value
    image_names          = ["helloworld:{{.Run.ID}}", "helloworld:latest"]
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "runacrtask" {
  container_registry_task_id = azurerm_container_registry_task.acr_task.id
}
