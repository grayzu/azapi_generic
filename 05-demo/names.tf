resource "random_pet" "rg_name" {
  prefix = "rg"
}

resource "random_pet" "acr_name" {
  prefix    = "acr"
  separator = ""
}
