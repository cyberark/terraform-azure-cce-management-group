# CCE Azure Management Group Onboarding Module

This Terraform module onboards Azure management groups to Connect Cloud Environments (CCE) CyberArk SaaS services.
CCE helps customers easily adopt CyberArk services and establish secure trust relationships with their Azure environments.

## Overview

This module automates the creation of Microsoft Entra ID applications, service principals, role assignments, and federated identity credentials required for CCE integration with Azure management groups.

## Features

* **Automated Management Group Onboarding**: Seamlessly onboard Azure management groups to CCE
* **Core CCE Application Setup**: Creates and configures the CCE application with required Microsoft Graph API permissions
* **Management Group Reader Role**: Assigns appropriate permissions at the management group scope
* **Workload Identity Federation**: Configures federated identity credentials for secure, passwordless authentication
* **SCA (Secure Cloud Access)**: When enabled with `shared_resources` from Commons, assigns the SCA resource app to the SCA resource custom role at this management group scope and registers SCA with CCE

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **CyberArk Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **Azure Requirements**
   - Microsoft Entra ID (formerly Azure AD) with appropriate permissions
   - Azure management group with appropriate access
   - Azure subscription for provider authentication

3. **Terraform Requirements**
   - Terraform >= 1.8.5
   - Microsoft Entra ID Provider
   - Azure RM Provider
   - CyberArk idsec Provider

4. **For SCA (Secure Cloud Access)**
   - Use the Commons module (`terraform-azure-cce-commons`) in your root configuration and pass its `sca` output as `sca.shared_resources` when enabling SCA at management group scope.

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

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| entra_id | The Microsoft Entra tenant ID | string | n/a | yes |
| management_group_id | The Azure management group ID | string | n/a | yes |
| sca.enable | Enable SCA at management group scope | bool | false | no |
| sca.shared_resources | SCA shared resources from Commons output (required when sca.enable = true). Must include resource_app_id, resource_custom_role_id, resource_wif_user_id. | object | null | no |

## Module Outputs

| Name | Description |
|------|-------------|
| cce_app_id | The CCE app (client) ID |
| sca_resource_app_id | The SCA Resource app (client) ID (when SCA enabled with shared_resources) |
| sca_resource_identity_user_id | The SCA Resource trusted username / WIF subject (when SCA enabled with shared_resources) |
| management_group_onboarding_id | The ID of the management group onboarding in CCE (null when no service is enabled) |

## What Gets Created

### In Azure

**CCE Application:**
* Microsoft Entra ID application: `CyberArk-CCE-app`
* Service principal for the CCE application
* Microsoft Graph API Permissions with admin consent:
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information
* Azure role assignment: `Management Group Reader` at the management group scope
* Federated Identity Credential for workload identity federation

**When SCA is enabled** (with `sca.enable = true` and `sca.shared_resources` from Commons):
* Role assignment of the SCA resource app (from Commons) to the SCA resource custom role at this management group scope
* SCA service registration in CCE for the management group

### In CyberArk

* Management group registration in CCE
* When SCA is enabled: SCA service resources for the management group

## Examples

See the [examples](./examples) directory for complete, working examples.

## Documentation

For more information about Connect Cloud Environments, see [CyberArk Documentation](https://docs.cyberark.com/admin-space/latest/en/content/cce/cce-overview.htm).

## Licensing

This repository is subject to the following licenses:
* **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).
* **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About

CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  
