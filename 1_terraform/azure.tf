provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  location = var.location
  name     = "rg-${var.prefix}"
}

resource "azurerm_container_registry" "acr" {
  sku                 = "Basic"
  admin_enabled       = true
  location            = azurerm_resource_group.main.location
  name                = replace(var.prefix, "-", "")
  resource_group_name = azurerm_resource_group.main.name
}
