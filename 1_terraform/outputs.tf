output "acr_url" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_name" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}
