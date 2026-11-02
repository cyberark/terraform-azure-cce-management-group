output "cce_app_id" {
  value       = module.cce_azure_management_group.cce_app_id
  description = "The CCE app (client) ID."
}

output "secrets_hub_app_id" {
  value       = module.cce_azure_shared.secrets_hub.app_id
  description = "The Secrets Hub app (client) ID (from commons)."
}

output "management_group_onboarding_id" {
  value       = module.cce_azure_management_group.management_group_onboarding_id
  description = "The management group onboarding ID in CCE."
}
