data "azurerm_key_vault" "kv" {
  name                = "kv-mc808080"
  resource_group_name = "common_infra"
}

data "azurerm_key_vault_secret" "gh_pat" {
  name         = "gh-pat-pub-only"
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

module "acr_task" {
  source = "./modules/docker_task"

  registry_id   = azurerm_container_registry.acr.id
  context       = "https://github.com/Azure-Samples/aci-helloworld.git#master"
  context_token = data.azurerm_key_vault_secret.gh_pat.value
  image_names   = ["helloworld:{{.Run.ID}}", "helloworld:latest"]
}

module "container_app" {
  source = "./modules/container_app"

  resource_group = {
    id       = azurerm_resource_group.rg.id
    location = azurerm_resource_group.rg.location
  }

  law = {
    workspace_id = azurerm_log_analytics_workspace.law.workspace_id
    shared_key   = azurerm_log_analytics_workspace.law.primary_shared_key
  }

  secrets = [{
    name  = "registry-password"
    value = azurerm_container_registry.acr.admin_password
  }]

  ingress = {
    target_port = 3333
    external    = true
  }

  containers = [
    {
      image = "${azurerm_container_registry.acr.login_server}/helloworld:latest",
      name  = "helloworld"
    }
  ]

  registries = [{
    password_ref = "registry-password"
    server       = azurerm_container_registry.acr.login_server
    username     = azurerm_container_registry.acr.admin_username
  }]

  depends_on = [module.acr_task]
}
