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
    idsec = {
      source  = "cyberark/idsec"
      version = "0.12.1"
    }
  }

  required_version = ">= 1.8.5"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azuread" {
}

provider "idsec" {
  # Configure your Idira credentials here or via environment variables
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

# Shared Secrets Hub resources (app, service principal, federated credential and
# custom role at the root management group). Apply once per tenant.
module "cce_azure_shared" {
  source  = "cyberark/cce-commons/azure"
  version = "0.8.1"

  entra_id = var.entra_id

  secrets_hub = {
    enable = true
  }
}

module "cce_azure_management_group" {
  source  = "cyberark/cce-management-group/azure"
  version = "0.7.0"

  entra_id            = var.entra_id
  management_group_id = var.management_group_id

  secrets_hub = {
    enable           = true
    shared_resources = module.cce_azure_shared.secrets_hub
  }
}
