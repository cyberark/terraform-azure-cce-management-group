output "cce_app_id" {
  value       = local.at_least_1_service_enabled ? module.cce[0].cce_app_id : null
  description = "The Application (client) ID of the CCE app"
}

