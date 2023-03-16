terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.44"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.4"
    }
  }
}

