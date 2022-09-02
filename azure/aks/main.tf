# Create an resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}