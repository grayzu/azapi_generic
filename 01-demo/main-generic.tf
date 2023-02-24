resource "azapi_resource" "container_app_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = random_pet.ca_env.id
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.law.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.law.primary_shared_key
        }
      }
    }
  })

  // properties/appLogsConfiguration/logAnalyticsConfiguration/sharedKey contains credential which will not be returned,
  // using this property to suppress plan-diff
  ignore_missing_property = true
}

resource "azapi_resource" "container_app" {
  type      = "Microsoft.App/containerApps@2022-01-01-preview"
  name      = random_pet.ca.id
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.container_app_environment.id
      configuration = {
        ingress = {
          targetPort = 3333
          external   = true
        }
        secrets = [
          {
            name  = "registry-password"
            value = azurerm_container_registry.acr.admin_password
          }
        ]
        registries = [
          {
            passwordSecretRef = "registry-password"
            server            = azurerm_container_registry.acr.login_server
            username          = azurerm_container_registry.acr.admin_username
          }
        ]
      }
      template = {
        containers = [
          {
            image = "${azurerm_container_registry.acr.login_server}/helloworld:latest",
            name  = "helloworld"
          }
        ]
      }
    }
  })

  // properties/configuration/secrets/value contains credential which will not be returned,
  // using this property to suppress plan-diff
  ignore_missing_property = true
  depends_on = [
    azurerm_container_registry_task_schedule_run_now.runacrtask
  ]
}
