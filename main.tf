terraform {
  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
    }
  }

  required_version = ">= 1.8.5"
}

data "idsec_cce_azure_identity_params" "get_wif_data" {}

locals {
  cce_wif_data               = data.idsec_cce_azure_identity_params.get_wif_data.identity_params["cloud_onboarding"]
  at_least_1_service_enabled = var.sca.enable == true
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
    resource_app_id         = var.sca.shared_resources.resource_app_id
    resource_custom_role_id = var.sca.shared_resources.resource_custom_role_id
    resource_wif_user_id    = var.sca.shared_resources.resource_wif_user_id
  }
}

# Create a simple Azure management group onboarding
resource "idsec_cce_azure_management_group" "create_management_group" {
  entra_id            = var.entra_id
  management_group_id = var.management_group_id
  count               = local.at_least_1_service_enabled ? 1 : 0
  cce_resources = {
    appId = module.cce[0].cce_app_id
  }

  depends_on = [module.sca]

  services = concat(
    # SCA service: resource app from sca submodule (resource-level only for MG, per sca.sh)
    var.sca.enable && var.sca.shared_resources != null ? [
      {
        service_name = "sca"
        resources = {
          applications = [
            {
              application_id            = var.sca.shared_resources.resource_app_id
              identity_trusted_username = var.sca.shared_resources.resource_wif_user_id
            }
          ]
        }
      }
    ] : []
  )
}
