output "cce_app_id" {
  value       = azuread_application.cce_app.client_id
  description = "The Application (client) ID of the CyberArk CCE app"
}

