resource "azapi_resource" "route1" {
  type      = "Microsoft.Network/routeTables/routes@2022-01-01"
  name      = random_pet.route_name[0].id
  parent_id = azurerm_route_table.rt.id
  body = jsonencode({
    properties = {
      nextHopType   = "VnetLocal"
      addressPrefix = "10.1.0.0/16"
    }
  })

  locks = [azurerm_route_table.rt.id]
}

resource "azapi_resource" "route2" {
  type      = "Microsoft.Network/routeTables/routes@2022-01-01"
  name      = random_pet.route_name[1].id
  parent_id = azurerm_route_table.rt.id
  body = jsonencode({
    properties = {
      nextHopType   = "VnetLocal"
      addressPrefix = "10.3.0.0/16"
    }
  })

  locks = [azurerm_route_table.rt.id]
}
