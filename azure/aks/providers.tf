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

    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.2.2"
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
  host                    = data.azurerm_kubernetes_cluster.aks_cluster_data.kube_config.0.host
  client_certificate      = base64decode(data.azurerm_kubernetes_cluster.aks_cluster_data.kube_config.0.client_certificate)
  client_key              = base64decode(data.azurerm_kubernetes_cluster.aks_cluster_data.kube_config.0.client_key)
  cluster_ca_certificate  = base64decode(data.azurerm_kubernetes_cluster.aks_cluster_data.kube_config.0.cluster_ca_certificate)
}

provider "azuredevops" {
  # Configuration options
}