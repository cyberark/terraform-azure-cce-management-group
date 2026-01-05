terraform {
  required_version = ">= 1.8.5"
}

# Placeholder for identity parameters
# Replace these with your actual values
locals {
  cce_wif_data = {
    identity_app_issuer   = "https://example.com/issuer"
    identity_user_id      = "placeholder-user-id"
    identity_app_audience = "placeholder-audience"
  }
}

module "cce" {
  source              = "./services_modules/cce"
  management_group_id = var.management_group_id
  identity_issuer     = local.cce_wif_data["identity_app_issuer"]
  identity_user_id    = local.cce_wif_data["identity_user_id"]
  identity_audience   = local.cce_wif_data["identity_app_audience"]
}
