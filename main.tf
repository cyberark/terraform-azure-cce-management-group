terraform {
  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "0.12.1"
    }
  }

  required_version = ">= 1.8.5"
}

data "idsec_cce_azure_identity_params" "get_wif_data" {}

locals {
  cce_wif_data               = data.idsec_cce_azure_identity_params.get_wif_data.identity_params["cloud_onboarding"]
  at_least_1_service_enabled = var.sca.enable == true || var.secrets_hub.enable == true || var.cds.enable == true
}

# Service versions this module registers in CCE. The commons module exposes the version of the resources it
# created in the `version` field of each service output, and the two must match: otherwise this module would
# register a service version whose resources (roles, apps, permissions) are not the ones commons created.
# Update the commons module to the release that matches this module before applying.
locals {
  sca_service_version         = "0.0.4"
  secrets_hub_service_version = "0.0.3"
  cds_service_version         = "2.1.0"
}

resource "terraform_data" "service_version_check" {
  lifecycle {
    precondition {
      condition     = !(var.sca.enable && var.sca.shared_resources != null) || try(var.sca.shared_resources.version, null) == local.sca_service_version
      error_message = "SCA version mismatch: this module registers SCA version ${local.sca_service_version}, but sca.shared_resources.version is '${coalesce(try(var.sca.shared_resources.version, null), "not set")}'. Update the commons module to the release that provides SCA version ${local.sca_service_version} and pass its sca output."
    }
    precondition {
      condition     = !(var.secrets_hub.enable && var.secrets_hub.shared_resources != null) || try(var.secrets_hub.shared_resources.version, null) == local.secrets_hub_service_version
      error_message = "Secrets Hub version mismatch: this module registers Secrets Hub version ${local.secrets_hub_service_version}, but secrets_hub.shared_resources.version is '${coalesce(try(var.secrets_hub.shared_resources.version, null), "not set")}'. Update the commons module to the release that provides Secrets Hub version ${local.secrets_hub_service_version} and pass its secrets_hub output."
    }
    precondition {
      condition     = !(var.cds.enable && var.cds.shared_resources != null) || try(var.cds.shared_resources.version, null) == local.cds_service_version
      error_message = "CDS version mismatch: this module registers CDS version ${local.cds_service_version}, but cds.shared_resources.version is '${coalesce(try(var.cds.shared_resources.version, null), "not set")}'. Update the commons module to the release that provides CDS version ${local.cds_service_version} and pass its cds output."
    }
  }
}

module "cce" {
  source              = "./modules/cce"
  management_group_id = var.management_group_id
  identity_issuer     = local.cce_wif_data["identity_app_issuer"]
  identity_user_id    = local.cce_wif_data["identity_user_id"]
  identity_audience   = local.cce_wif_data["identity_app_audience"]
  count               = local.at_least_1_service_enabled ? 1 : 0
}

module "sca" {
  source              = "./modules/sca"
  count               = var.sca.enable && var.sca.shared_resources != null ? 1 : 0
  management_group_id = var.management_group_id
  shared_resources = {
    resource_app_id                   = var.sca.shared_resources.resource_app_id
    resource_custom_role_id           = var.sca.shared_resources.resource_custom_role_id
    resource_wif_user_id              = var.sca.shared_resources.resource_wif_user_id
    add_permissions_to_manage_cluster = try(var.sca.shared_resources.add_permissions_to_manage_cluster, false)
    resource_k8s_custom_role_id       = try(var.sca.shared_resources.resource_k8s_custom_role_id, null)
  }

  depends_on = [terraform_data.service_version_check]
}

module "secrets_hub" {
  source              = "./modules/secrets_hub"
  count               = var.secrets_hub.enable ? 1 : 0
  management_group_id = var.management_group_id
  shared_resources    = var.secrets_hub.shared_resources

  depends_on = [terraform_data.service_version_check]
}

module "cds" {
  source              = "./modules/cds"
  count               = var.cds.enable && var.cds.shared_resources != null ? 1 : 0
  management_group_id = var.management_group_id
  shared_resources = {
    resource_app_id         = var.cds.shared_resources.resource_app_id
    resource_custom_role_id = var.cds.shared_resources.resource_custom_role_id
  }

  depends_on = [terraform_data.service_version_check]
}

# Create a simple Azure management group onboarding
resource "idsec_cce_azure_management_group" "create_management_group" {
  entra_id            = var.entra_id
  management_group_id = var.management_group_id
  cce_version         = "0.0.1"
  count               = local.at_least_1_service_enabled ? 1 : 0
  cce_resources = {
    appId = module.cce[0].cce_app_id
  }

  depends_on = [module.sca, module.secrets_hub, module.cds]

  # flatten, not concat: the services' resources have different types
  services = flatten([
    # SCA service: Resource app from SCA submodule (resource-level only for management group, per sca.sh)
    var.sca.enable && var.sca.shared_resources != null ? [
      {
        service_name = "sca"
        version      = local.sca_service_version
        resources = {
          applications = [
            {
              application_id            = var.sca.shared_resources.resource_app_id
              identity_trusted_username = var.sca.shared_resources.resource_wif_user_id
            }
          ]
          add_permissions_to_manage_cluster = try(var.sca.shared_resources.add_permissions_to_manage_cluster, false)
        }
      }
    ] : [],
    # Secrets Hub service: app from commons, role assignments at this management group. This mirrors the reference Secrets Hub onboarding script; no wait is needed before registration because depends_on already orders the role assignments first.
    var.secrets_hub.enable ? [
      {
        service_name = "secrets_hub"
        version      = local.secrets_hub_service_version
        resources = {
          applications = [
            {
              application_id            = var.secrets_hub.shared_resources.app_id
              identity_trusted_username = var.secrets_hub.shared_resources.identity_trusted_username
            }
          ]
        }
      }
    ] : [],

    var.cds.enable && var.cds.shared_resources != null ? [
      {
        service_name = "cds"
        version      = local.cds_service_version
        resources = {
          application_ids = [
            var.cds.shared_resources.entra_app_id,
            var.cds.shared_resources.resource_app_id,
          ]
          applications = [
            {
              application_id            = var.cds.shared_resources.entra_app_id
              identity_trusted_username = var.cds.shared_resources.entra_wif_user_id
            },
            {
              application_id            = var.cds.shared_resources.resource_app_id
              identity_trusted_username = var.cds.shared_resources.resource_wif_user_id
            }
          ]
        }
      }
    ] : []
  ])
}
