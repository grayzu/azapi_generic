terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.4"
    }
  }
}
