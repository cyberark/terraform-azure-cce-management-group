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

provider "azurerm" {
  subscription_id = "34ea05f7-b5bb-40cd-944e-0f8ba82dc4d9" # Replace with your required subscription id
  features {}
}

provider "azuread" {
}

module "cce_azure_management_group" {
  source              = "../../"
  entra_id            = var.entra_id
  management_group_id = var.management_group_id
}

