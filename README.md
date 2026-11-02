# CCE Azure Management Group Onboarding Module

This Terraform module onboards Azure management groups to Connect cloud environments (CCE) Idira SaaS services.
CCE helps customers easily adopt Idira services and establish secure trust relationships with their Azure environments.

## Overview

This module automates the creation of Microsoft Entra ID applications, service principals, role assignments, and federated identity credentials required for CCE integration with Azure management groups.

## Features

* **Automated Management Group Onboarding**: Seamlessly onboard Azure management groups to CCE
* **Core CCE Application Setup**: Creates and configures the CCE application with required Microsoft Graph API permissions
* **Management Group Reader Role**: Assigns appropriate permissions at the management group scope
* **Workload Identity Federation**: Configures federated identity credentials for secure, passwordless authentication
* **SCA (Secure Cloud Access)**: When enabled with `shared_resources` from Commons, assigns the SCA resource app to the SCA resource custom role at this management group scope and registers SCA with CCE
* **Secrets Hub**: When enabled with `shared_resources` from Commons, assigns the Secrets Hub custom role and the built-in `Key Vault Secrets Officer` role to the Secrets Hub service principal at this management group scope and registers Secrets Hub with CCE
* **Cloud Discovery**: When enabled with `shared_resources` from Commons, assigns the Cloud Discovery resource app to the Cloud Discovery resource custom role at this management group scope and registers Cloud Discovery with CCE

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **Idira Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **Azure Requirements**
   - Microsoft Entra ID (formerly Azure AD) with appropriate permissions
   - Azure management group with appropriate access
   - Azure subscription for provider authentication
   - Application Administrator role in Microsoft Entra ID, to create the CCE application
   - Owner or User Access Administrator at the management group scope, to create role assignments

3. **Terraform Requirements**
   - Terraform >= 1.8.5
   - Microsoft Entra ID Provider
   - Azure RM Provider
   - Idira idsec Provider

4. **For SCA (Secure Cloud Access)**
   - Use the Commons module (`terraform-azure-cce-commons`) in your root configuration and pass its `sca` output as `sca.shared_resources` when enabling SCA at management group scope.

5. **For Secrets Hub**
   - Secrets Hub is activated on your Idira tenant.
   - Use the Commons module (`terraform-azure-cce-commons`) version 0.8.1 or later with `secrets_hub = { enable = true }`, and pass its `secrets_hub` output (for example `module.cce_azure_shared.secrets_hub`) as `secrets_hub.shared_resources`. Apply Commons once per tenant.
   - Do not enable Secrets Hub in both this module and the Entra module for the same tenant. A tenant is onboarded with Secrets Hub at one scope only.
   - Use either Terraform or the CCE onboarding script for a tenant, not both.

6. **For Cloud Discovery**
   - Use the Commons module (`terraform-azure-cce-commons`) with `cds.enable = true` in your root configuration and pass its `cds` output as `cds.shared_resources`. See the `examples/cloud_discovery_onboarding` example ("Onboard Specific Management Groups or Subscriptions" section) in `terraform-azure-cce-commons`.

## Usage

### Basic Example

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
}
```

### With SCA Enabled

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
  sca = {
    enable           = true
    shared_resources = module.cce_azure_shared.sca  # From terraform-azure-cce-commons
  }
}
```

### With Cloud Discovery Enabled

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
  cds = {
    enable           = true
    shared_resources = module.cce_azure_shared.cds  # From terraform-azure-cce-commons
  }
}
```

### With Secrets Hub Enabled

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
  secrets_hub = {
    enable           = true
    shared_resources = module.cce_azure_shared.secrets_hub  # From terraform-azure-cce-commons
  }
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| entra_id | The Microsoft Entra tenant ID | string | n/a | yes |
| management_group_id | The Azure management group ID | string | n/a | yes |
| sca.enable | Enable SCA at management group scope | bool | false | no |
| sca.shared_resources | SCA shared resources from Commons output (required when sca.enable = true). Must include resource_app_id, resource_custom_role_id, resource_wif_user_id. | object | null | no |
| sca.shared_resources.add_permissions_to_manage_cluster | When true, assigns the K8s custom role at this management group scope. Requires `resource_k8s_custom_role_id` to be non-empty. | bool | false | no |
| sca.shared_resources.resource_k8s_custom_role_id | The K8s custom role ID from Commons output (required when `add_permissions_to_manage_cluster` is true). | string | null | no |
| secrets_hub.enable | Enable Secrets Hub at management group scope | bool | false | no |
| secrets_hub.shared_resources | Secrets Hub shared resources from Commons output (required when secrets_hub.enable = true). Must include app_id, custom_role_id, identity_trusted_username. | object | null | no |
| cds.enable | Enable Cloud Discovery at management group scope | bool | false | no |
| cds.shared_resources | Cloud Discovery shared resources from Commons output (required when cds.enable = true). Must include entra_app_id, entra_wif_user_id, resource_app_id, resource_custom_role_id, resource_wif_user_id. | object | null | no |

## Module Outputs

| Name | Description |
|------|-------------|
| cce_app_id | The CCE app (client) ID |
| sca_resource_app_id | The SCA Resource app (client) ID (when SCA enabled with shared_resources) |
| sca_resource_identity_user_id | The SCA Resource trusted username / WIF subject (when SCA enabled with shared_resources) |
| management_group_onboarding_id | The ID of the management group onboarding in CCE (null when no service is enabled) |

Secrets Hub does not add any module outputs.

## What Gets Created

### In Azure

**CCE Application:**
* Microsoft Entra ID application: `Idira-CCE-app`
* Service principal for the CCE application
* Microsoft Graph API Permissions with admin consent:
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information
* Azure role assignment: `Management Group Reader` at the management group scope
* Federated Identity Credential for workload identity federation

**When SCA is enabled** (with `sca.enable = true` and `sca.shared_resources` from Commons):
* Role assignment of the SCA resource app (from Commons) to the SCA resource custom role at this management group scope
* SCA service registration in CCE for the management group
* When `shared_resources.add_permissions_to_manage_cluster` is true, assigns the K8s custom role at this management group scope

**When Secrets Hub is enabled** (with `secrets_hub.enable = true` and `secrets_hub.shared_resources` from Commons):
* Role assignment of the Secrets Hub service principal (from Commons) to the Secrets Hub custom role at this management group scope
* Role assignment of the Secrets Hub service principal to the built-in `Key Vault Secrets Officer` role at this management group scope
* Secrets Hub service registration in CCE for the management group

**When Cloud Discovery is enabled** (with `cds.enable = true` and `cds.shared_resources` from Commons):
* Role assignment of the Cloud Discovery resource app (from Commons) to the Cloud Discovery resource custom role at this management group scope.
* Cloud Discovery service registration in CCE for the management group, including both Cloud Discovery apps (Entra and resource). The apps, custom roles, and the Entra app's root management group assignment are created by Commons.
* To offboard Cloud Discovery, set `cds.enable = false` and apply. Only after every level is offboarded, disable Cloud Discovery in Commons and apply to delete the shared resources. Do not remove the module block or run `terraform destroy`. This will offboard every service, not only Cloud Discovery.

### In Idira

* Management group registration in CCE
* When SCA is enabled: SCA service resources for the management group
* When Cloud Discovery is enabled: Cloud Discovery service resources for the management group
* When Secrets Hub is enabled: Secrets Hub service registration for the management group

## Secrets Hub

Secrets Hub is onboarded at one scope only. Do not enable it in both this module and the Entra module for the same tenant.

### Resources Created

**In this module** (when `secrets_hub.enable = true`), at `/providers/Microsoft.Management/managementGroups/<management_group_id>`:
* Role assignment of the Secrets Hub custom role `idira-secrets-hub-role-<t>-<e>` (from Commons) to the Secrets Hub service principal
* Role assignment of the built-in `Key Vault Secrets Officer` role to the Secrets Hub service principal

In the role name, `<t>` is the tenant ID suffix and `<e>` is the Entra ID suffix that the Commons module appends to its resource names. See the `terraform-azure-cce-commons` documentation for details.

**In Commons** (see `terraform-azure-cce-commons`; not created by this module):
* The application and service principal `idira-secrets-hub-app-<t>-<e>`
* The federated identity credential `Idira-SecretsHub-Azure-Access`
* The custom role definition, which stays at the root management group and is not duplicated here. Its actions are:
  * `Microsoft.KeyVault/vaults/read`, `Microsoft.KeyVault/vaults/secrets/read`, `Microsoft.KeyVault/vaults/secrets/write`
  * `Microsoft.Resources/subscriptions/read`, `Microsoft.Resources/subscriptions/resourceGroups/read`, `Microsoft.Resources/subscriptions/resources/read`
  * `Microsoft.ResourceGraph/resources/read`

**In CCE:** the Secrets Hub service registration on the management group onboarding.

### Limitations

* Only Key Vaults that use Azure role-based access control are covered. Key Vaults that use access policies are not covered; migrate them to Azure role-based access control to use Secrets Hub with them.

### Removing Secrets Hub

Commons and this module are used from the same root configuration. To remove Secrets Hub, set `secrets_hub.enable = false` in **both** the Commons module and this module, then run a single `terraform apply`. This offboards Secrets Hub from CCE and deletes its role assignments, application, service principal, federated credential and custom role. Running `terraform destroy` removes all resources managed by the configuration, not only Secrets Hub.

Use the same procedure to clean up after a partial apply in which the CCE registration failed. In that case the Azure resources already exist, but Secrets Hub is not registered in CCE.

Do not disable Secrets Hub in Commons alone while this module still consumes its output. `terraform plan` fails because the referenced output no longer exists. Disable both in the same apply.

## Examples

See the [examples](./examples) directory for complete, working examples, including the [Basic Example](./examples/basic) and the [Secrets Hub Example](./examples/secrets_hub).

## Documentation

For more information about Connect cloud environments, see [CyberArk Documentation](https://docs.cyberark.com/admin-space/latest/en/content/cce/cce-overview.htm).

## Licensing

This repository is subject to the following licenses:
* **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).
* **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About

Idira is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  
