# Create an resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}

# Create an application
resource "azuread_application" "myapp" {
  display_name = var.app-name
}
