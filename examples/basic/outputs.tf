output "cce_app_id" {
  value       = module.cce_azure_management_group.cce_app_id
  description = "The Application (client) ID of the CCE app"
}

output "sca_resource_app_id" {
  value       = module.cce_azure_management_group.sca_resource_app_id
  description = "The SCA Resource app ID (from commons when sca is enabled with shared_resources)"
}

output "sca_resource_identity_user_id" {
  value       = module.cce_azure_management_group.sca_resource_identity_user_id
  description = "The SCA Resource trusted username (from commons when sca is enabled with shared_resources)"
}