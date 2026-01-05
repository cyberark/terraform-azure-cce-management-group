# Azure Management Group Onboarding to CyberArk CCE

## Overview

This Terraform module simplifies the onboarding of Azure Management Groups to CyberArk CCE (Connect Cloud Environments). It automates the creation of Azure AD applications, service principals, role assignments, and federated identity credentials required for CCE integration with Azure Management Groups.

## Features

* **Automated Management Group Onboarding**: Seamlessly onboard Azure Management Groups to CyberArk CCE
* **Core CCE Application Setup**: Creates and configures the CCE application with required Microsoft Graph API permissions
* **Management Group Reader Role**: Assigns appropriate permissions at the Management Group scope
* **Workload Identity Federation**: Configures federated identity credentials for secure, passwordless authentication
* **Optional Services Support**: Modular design allows enabling additional CCE services
* **Flexible Configuration**: Enable or disable optional services based on your requirements

## Prerequisites

* Azure Entra ID (formerly Azure AD) with appropriate permissions
* Azure Management Group with appropriate access
* Azure subscription for provider authentication
* CyberArk tenant with CCE enabled
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured - [Documentation](https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage)

## Usage

### Basic Example

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
  dummy               = { enable = true }
}
```

### Full Example with All Services

```hcl
module "cce_azure_management_group" {
  source              = "path/to/module"
  entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
  management_group_id = "my-management-group-id"
  dummy               = { enable = true }
  dummy_two           = { enable = true }
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| entra_id | The Azure Entra (Tenant) ID | string | n/a | yes |
| management_group_id | The Azure Management Group ID | string | n/a | yes |
| dummy | Configuration for the dummy service | object({ enable = bool }) | { enable = false } | no |
| dummy_two | Configuration for the dummy two service | object({ enable = bool }) | { enable = false } | no |

## Module Outputs

| Name | Description |
|------|-------------|
| cce_app_id | The Application (client) ID of the CCE app |
| dummy_app_id | The Application (client) ID of the CyberArk Dummy app (if enabled) |
| dummy_two_app_id | The Application (client) ID of the CyberArk Dummy Two app (if enabled) |

## What Gets Created

### In Azure

**CCE Application:**
* Azure AD Application: `CyberArk-CCE-app`
* Service Principal for the CCE application
* Microsoft Graph API Permissions with admin consent:
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information
* Azure Role Assignment: `Management Group Reader` at the Management Group scope
* Federated Identity Credential for workload identity federation

**Optional Services (when enabled):**
* Additional Azure AD Applications and Service Principals
* Service-specific permissions and role assignments
* Federated Identity Credentials for each service

### In CyberArk

* Management Group registration in CCE
* Enabled optional services (Dummy, Dummy Two) based on configuration

## Examples

This repository includes two complete examples:

* [**basic**](examples/basic/) - Simple onboarding with one optional service
* [**full_services**](examples/full_services/) - Complete onboarding with multiple optional services

## Documentation

For more information about CyberArk CCE and Azure Management Group integration, refer to the CyberArk documentation.

## Licensing

This repository is subject to the following licenses:
* **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).
* **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About

CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  