terraform {
  required_version = ">= 1.8.5"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Look up the Secrets Hub app's service principal (from commons)
data "azuread_service_principal" "secrets_hub_sp" {
  client_id = var.shared_resources.app_id
}

# Assign the Secrets Hub custom role (defined at the root management group by commons) at this management group scope
resource "azurerm_role_assignment" "secrets_hub_custom_role" {
  scope              = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  role_definition_id = var.shared_resources.custom_role_id
  principal_id       = data.azuread_service_principal.secrets_hub_sp.object_id
}

# Assign the built-in Key Vault Secrets Officer role at this management group scope
resource "azurerm_role_assignment" "secrets_hub_kv_secrets_officer" {
  scope                = "/providers/Microsoft.Management/managementGroups/${var.management_group_id}"
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_service_principal.secrets_hub_sp.object_id
}
