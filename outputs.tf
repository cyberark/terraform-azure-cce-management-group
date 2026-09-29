output "cce_app_id" {
  value       = local.at_least_1_service_enabled ? module.cce[0].cce_app_id : null
  description = "The CCE app (client) ID."
}

# SCA outputs come from commons (shared_resources); same format whether commons created or passed through
output "sca_resource_app_id" {
  value       = var.sca.enable && var.sca.shared_resources != null ? var.sca.shared_resources.resource_app_id : null
  description = "The SCA resource app ID (from commons when SCA is enabled with shared_resources)."
}

output "sca_resource_identity_user_id" {
  value       = var.sca.enable && var.sca.shared_resources != null ? var.sca.shared_resources.resource_wif_user_id : null
  description = "The SCA resource trusted username / WIF subject (from commons)."
}

output "management_group_onboarding_id" {
  value       = length(idsec_cce_azure_management_group.create_management_group) > 0 ? idsec_cce_azure_management_group.create_management_group[0].id : null
  description = "The management group onboarding resource ID. Returns null when no service is enabled."
}

