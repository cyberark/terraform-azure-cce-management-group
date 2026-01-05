output "cce_app_id" {
  value       = module.cce_azure_management_group.cce_app_id
  description = "The Application (client) ID of the CCE app"
}

output "dummy_app_id" {
  value       = module.cce_azure_management_group.dummy_app_id
  description = "The Application (client) ID of the CyberArk Dummy app"
}