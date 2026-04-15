# Example: Basic CCE Management Group Onboarding

This example demonstrates a basic configuration to onboard an Azure management group to Connect cloud environments (CCE).

## What This Example Does

* Onboards your Azure management group to CCE
* Creates the core CCE application with required permissions
* Optionally enables SCA at management group scope (see step 2 below)  

## Prerequisites

* Microsoft Entra ID (formerly Azure AD) with appropriate permissions
* Azure management group with appropriate access
* Azure subscription for provider authentication
* CyberArk tenant with CCE
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage  

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:

    ```hcl
    entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
    management_group_id = "my-management-group-id"
    ```

2. (Optional) To enable SCA at management group scope, pass `sca` with `shared_resources` from your CCE Azure Commons module output in the module block:

    ```hcl
    module "cce_azure_management_group" {
      source              = "../../"
      entra_id            = var.entra_id
      management_group_id = var.management_group_id
      sca = {
        enable = true
        shared_resources = module.cce_azure_shared.sca  # from terraform-azure-cce-commons
      }
    }
    ```

3. Initialize Terraform:  

    ```bash
    terraform init
    ```

4. Review the plan:  

    ```bash
    terraform plan
    ```

5. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

**CCE Application:**
* Microsoft Entra ID application: `CyberArk-CCE-app`  
* Service principal for the CCE application  
* Microsoft Graph API Permissions with admin consent for CCE app:  
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information  
* Azure role assignment: `Management Group Reader` at the management group scope
* Federated Identity Credential for workload identity federation

**When SCA is enabled** (with `sca.enable = true` and `sca.shared_resources` from commons):
* Role assignment of the SCA resource app (from commons) to the SCA resource custom role at this management group scope
* SCA service registration in CCE for the management group

### In CyberArk

* Management group registration in CCE
* When SCA is enabled: SCA service resources for the management group

## Outputs

This example outputs:

* `cce_app_id`: The CCE app (client) ID
* `sca_resource_app_id`: The SCA Resource app ID (when SCA is enabled with shared_resources from Commons)
* `sca_resource_identity_user_id`: The SCA Resource trusted username (when SCA is enabled with shared_resources)

## Next Steps

After successful deployment:

1. Verify the management group appears in your CCE console
