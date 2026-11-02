# Example: Secrets Hub on an Azure Management Group

This example onboards an Azure management group to Connect cloud environments (CCE) with Secrets Hub enabled.

## What This Example Does

* Applies the Commons module once to create the shared Secrets Hub app, service principal, federated credential and custom role (defined at the root management group)
* Onboards your management group to CCE and registers Secrets Hub
* Assigns the Secrets Hub custom role and `Key Vault Secrets Officer` at the management group scope

## Prerequisites

* Microsoft Entra ID with **Application Administrator**, and **Owner** or **User Access Administrator** at the root management group
* Azure management group and a subscription for provider authentication
* Idira tenant with CCE and Secrets Hub activated
* Terraform >= 1.8.5
* Idira `idsec` provider (`0.12.1`) configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage

Secrets Hub is onboarded at one scope only: use either the management group module or the Entra module for a tenant, not both. Only Key Vaults that use Azure role-based access control are covered.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`

## Removing Secrets Hub

Set `secrets_hub.enable = false` in both the Commons module and the management group module, then run one `terraform apply`. `terraform destroy` removes everything.

## Outputs

* `cce_app_id`: The CCE app (client) ID
* `secrets_hub_app_id`: The Secrets Hub app (client) ID
* `management_group_onboarding_id`: The management group onboarding ID in CCE
