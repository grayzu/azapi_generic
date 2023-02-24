resource "azurerm_container_registry_task" "acr_task" {
  name                  = random_pet.acrtask_name.id
  container_registry_id = var.registry_id
  platform {
    os = "Linux"
  }
  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = var.context
    context_access_token = var.context_token
    image_names          = var.image_names
  }

}

resource "azurerm_container_registry_task_schedule_run_now" "runacrtask" {
  container_registry_task_id = azurerm_container_registry_task.acr_task.id
}
