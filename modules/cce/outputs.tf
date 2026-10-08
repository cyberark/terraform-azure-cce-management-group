output "cce_app_id" {
  value       = azuread_application.cce_app.client_id
  description = "The CCE app (client) ID."
}

