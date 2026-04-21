terraform {
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

  required_version = ">= 1.8.5"
}

# Role assignment scope logic
locals {
  role_prefix = "/providers/Microsoft.Management/managementGroups"
  role_scope  = "${local.role_prefix}/${var.management_group_id}"
}


# Data source to get Microsoft Graph API details
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

# Create the CCE Application
resource "azuread_application" "cce_app" {
  display_name = "CyberArk-CCE-app"

  # Required resource access for Microsoft Graph
  required_resource_access {
    # Microsoft Graph API
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    # CrossTenantInformation.ReadBasic.All permission
    resource_access {
      id   = "cac88765-0581-4025-9725-5ebc13f729ee"
      type = "Role"
    }
  }
}

# Create a service principal for the application
resource "azuread_service_principal" "cce_app_sp" {
  client_id = azuread_application.cce_app.client_id
}

# Grant admin consent for CrossTenantInformation.ReadBasic.All
resource "azuread_app_role_assignment" "msgraph_crosstenant_read" {
  app_role_id         = "cac88765-0581-4025-9725-5ebc13f729ee"
  principal_object_id = azuread_service_principal.cce_app_sp.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Create federated identity credential for the application
resource "azuread_application_federated_identity_credential" "cce_credentials" {
  application_id = azuread_application.cce_app.id
  display_name   = "connect-cloud-environments"
  description    = "Federated credential for cce"
  issuer         = var.identity_issuer
  subject        = var.identity_user_id
  audiences      = [var.identity_audience]
}

# Assign "Management Group Reader" role to the service principal
resource "azurerm_role_assignment" "cce_management_group_reader" {
  scope                = local.role_scope
  role_definition_name = "Management Group Reader"
  principal_id         = azuread_service_principal.cce_app_sp.object_id
}
