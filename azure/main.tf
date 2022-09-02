# Create an resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg-name
  location = var.location
}

# Create an application
resource "azuread_application" "my-app" {
  display_name = var.app-name
}

data "azuread_application" "app-reg" {
  display_name = var.app-name
  
  depends_on = [azuread_application.my-app]
}

resource "time_rotating" "passwd-time-rotation" {
  rotation_minutes = var.password-rotation-minutes
}

resource "azuread_application_password" "app-pass" {
  application_object_id = data.azuread_application.app-reg.object_id
  #end_date_relative = var.password-valid-duration
  rotate_when_changed = {
    rotation = time_rotating.passwd-time-rotation.id
  }
}

data "azurerm_key_vault" "kv" {
  name                = var.kv-name
  resource_group_name = var.rg-name

  depends_on = [azurerm_key_vault.key-vault]
}

resource "azurerm_key_vault_secret" "sp_client_id" {
  name         = var.client-id
  value        = data.azuread_application.app-reg.application_id
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = var.client-secret
  value        =  azuread_application_password.app-pass.value
  key_vault_id = data.azurerm_key_vault.kv.id
}