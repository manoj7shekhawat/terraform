# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.27.0"
    }
  }

  required_version = ">= 1.2.7"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  # Configuration options
}