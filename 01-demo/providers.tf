terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
    }

    azurerm = {
      source = "hashicorp/azurerm"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

