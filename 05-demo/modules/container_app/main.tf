resource "azapi_resource" "container_app_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = random_pet.ca_env.id
  parent_id = var.resource_group.id
  location  = var.resource_group.location

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.law.workspace_id
          sharedKey  = var.law.shared_key
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
  parent_id = var.resource_group.id
  location  = var.resource_group.location

  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.container_app_environment.id
      configuration = {
        ingress = {
          targetPort = var.ingress.target_port
          external   = var.ingress.external
        }
        secrets    = var.secrets
        registries = var.registries
      }
      template = {
        containers = var.containers
      }
    }
  })

  // properties/configuration/secrets/value contains credential which will not be returned,
  // using this property to suppress plan-diff
  ignore_missing_property = true
}
