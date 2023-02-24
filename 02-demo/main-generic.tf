
data "azapi_resource" "appsettings" {
  type                   = "Microsoft.Web/sites/config@2022-03-01"
  parent_id              = azurerm_linux_function_app.function.id
  name                   = "appsettings"
  response_export_values = ["*"]
}

output "no-app-settings" {
  // appsettings can't be fetched with azapi_resource data source directly
  value = jsondecode(data.azapi_resource.appsettings.output)
}

data "azapi_resource_action" "list" {
  type                   = "Microsoft.Web/sites/config@2022-03-01"
  resource_id            = data.azapi_resource.appsettings.id
  action                 = "list"
  method                 = "POST"
  response_export_values = ["*"]
}

output "app-settings" {
  // appsettings can only be fetched with list action
  value = jsondecode(data.azapi_resource_action.list.output)
}

resource "azapi_resource_action" "update" {
  type        = "Microsoft.Web/sites/config@2022-03-01"
  resource_id = data.azapi_resource.appsettings.id
  method      = "PUT"

  body = jsonencode({
    name = "appsettings"
    // use merge function to combine new settings with existing ones
    properties = merge(
      jsondecode(data.azapi_resource_action.list.output).properties,
      {
        WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
      }
    )
  })
  response_export_values = ["*"]
}
