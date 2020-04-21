data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault" {
  name     = "advent-kv"
  location = var.location
}

resource "random_id" "some_id" {
  byte_length = 8
}

resource "azurerm_key_vault" "advent" {
  name                = format("%s%s", "advent", random_id.some_id.hex)
  location            = azurerm_resource_group.keyvault.location
  resource_group_name = azurerm_resource_group.keyvault.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.aks_user_msi.principal_id

    secret_permissions = [
      "get",
      "list",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "get",
      "set",
      "list",
      "delete",
    ]
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_key_vault_secret" "advent" {
  name         = "everything"
  value        = "42"
  key_vault_id = azurerm_key_vault.advent.id

  tags = {
    environment = "Production"
  }
}
