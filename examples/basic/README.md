# Example: Basic CCE Management Group Onboarding

This example demonstrates a basic configuration to onboard an Azure Management Group to CyberArk CCE (Connect Cloud Environments).

## What This Example Does

* Onboards your Azure Management Group to CyberArk CCE
* Creates the core CCE application with required permissions

## Prerequisites

* Azure Entra ID (formerly Azure AD) with appropriate permissions
* Azure Management Group with appropriate access
* Azure subscription for provider authentication
* Terraform >= 1.8.5

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:

    ```hcl
    entra_id            = "0b659685-1a00-43cd-b994-555bac390ecf"
    management_group_id = "my-management-group-id"
    ```

2. Initialize Terraform:  

    ```bash
    terraform init
    ```

3. Review the plan:  

    ```bash
    terraform plan
    ```

4. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

**CCE Application:**
* Azure AD Application: `CyberArk-CCE-app`  
* Service Principal for the CCE application  
* Microsoft Graph API Permissions with admin consent for CCE app:  
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information  
* Azure Role Assignment: `Management Group Reader` at the Management Group scope  
* Federated Identity Credential for workload identity federation  

## Outputs

This example outputs:

* `cce_app_id`: The Application (client) ID of the CCE app   

## Next Steps

After successful deployment:

1. Verify the Management Group appears in your CyberArk CCE console  
