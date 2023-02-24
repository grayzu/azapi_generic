data "azapi_resource_action" "rg_vmss" {
  type        = "Microsoft.Resources/resourceGroups@2021-04-01"
  resource_id = data.azurerm_resource_group.aks_mc_rg.id
  action      = "providers/Microsoft.Compute/virtualMachineScaleSets"
  method      = "GET"

  response_export_values = ["*"]
}

resource "azapi_resource_action" "aks_vmss_id_update" {
  type        = "Microsoft.Compute/virtualMachineScaleSets@2022-03-01"
  resource_id = jsondecode(data.azapi_resource_action.stuff.output).value[0].id
  // omit `action` field or set it to empty string like `action = ""`, to make request towards the resource
  method = "PATCH"

  body = jsonencode({
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (azurerm_user_assigned_identity.uai.id) = {}
      }
    }
  })
}
