# Create an resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks-name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns-prefix

  default_node_pool {
    name       = var.node-pool-name
    node_count = 1
    vm_size    = var.node-pool-size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}