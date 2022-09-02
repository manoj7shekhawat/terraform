# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.21.1"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }

  required_version = ">= 1.2.8"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "kubernetes" {
  # Configuration options
}