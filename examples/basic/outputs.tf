output "cce_app_id" {
  value       = module.cce_azure_management_group.cce_app_id
  description = "The CCE app (client) ID."
}

output "sca_resource_app_id" {
  value       = module.cce_azure_management_group.sca_resource_app_id
  description = "The SCA resource app ID (from commons when SCA is enabled with shared_resources)."
}

output "sca_resource_identity_user_id" {
  value       = module.cce_azure_management_group.sca_resource_identity_user_id
  description = "The SCA resource trusted username (from commons when SCA is enabled with shared_resources)."
}