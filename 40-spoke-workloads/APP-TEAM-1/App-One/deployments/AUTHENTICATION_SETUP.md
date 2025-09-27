# Azure Authentication Setup for GitHub Actions

This guide walks you through setting up authentication between GitHub Actions and Azure using a Service Principal.

## Prerequisites

- Azure CLI installed locally
- GitHub repository with Admin access
- Azure subscription access (Contributor role minimum)

## Step 1: Create Azure Service Principal

Run these commands in your terminal (PowerShell/Command Prompt):

### 1.1 Login to Azure
```bash
az login
```

### 1.2 Set your subscription
```bash
az account set --subscription "{subscription-id}"
```

### 1.3 Create the Service Principal
```bash
az ad sp create-for-rbac --name "sp-github-terraform-storage" \
  --role "Contributor" \
  --scopes "/subscriptions/{subscription-id}" \
  --sdk-auth
```

**Important:** Save the output JSON - you'll need it for GitHub secrets!

Example output:
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-client-secret-here",
  "subscriptionId": "{subscription-id}",
  "tenantId": "87654321-4321-4321-4321-210987654321",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

## Step 2: Create Terraform State Storage

Terraform needs a place to store its state file. Create a storage account for this:

### 2.1 Create Resource Group for Terraform State
```bash
az group create --name "rg-terraform-state" --location "East US"
```

### 2.2 Create Storage Account for Terraform State
```bash
# Generate a unique storage account name
$storageAccountName = "tfstate$(Get-Random -Minimum 100000 -Maximum 999999)"

az storage account create \
  --resource-group "rg-terraform-state" \
  --name $storageAccountName \
  --sku "Standard_LRS" \
  --encryption-services blob
```

### 2.3 Create Storage Container
```bash
az storage container create \
  --name "tfstate" \
  --account-name $storageAccountName
```

### 2.4 Save the Storage Account Name
**Important:** Note down the `$storageAccountName` value - you'll need it for GitHub secrets!

## Step 3: Configure GitHub Secrets

Go to your GitHub repository â†’ Settings â†’ Secrets and variables â†’ Actions

Create these **Repository Secrets**:

### 3.1 AZURE_CREDENTIALS
Paste the entire JSON output from Step 1.3:
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-client-secret-here",
  "subscriptionId": "{subscription-id}",
  "tenantId": "87654321-4321-4321-4321-210987654321",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### 3.2 TERRAFORM_STATE_RG
```
rg-terraform-state
```

### 3.3 TERRAFORM_STATE_STORAGE
```
tfstate123456  # Use the actual storage account name from Step 2.2
```

## Step 4: Create GitHub Environment

1. Go to your repository â†’ Settings â†’ Environments
2. Click "New environment"
3. Name it `development`
4. Click "Create environment"
5. Under "Environment protection rules", you can optionally:
   - Add required reviewers
   - Add deployment protection rules

## Step 5: Test the Setup

### 5.1 Verify Service Principal Permissions
```bash
az login --service-principal \
  --username "your-client-id" \
  --password "your-client-secret" \
  --tenant "your-tenant-id"

# Test access
az group list --output table
```

### 5.2 Test Terraform State Access
```bash
az storage blob list \
  --container-name "tfstate" \
  --account-name "your-storage-account-name" \
  --auth-mode login
```

## Step 6: Update Storage Account Name

**Important:** Before deploying, update the storage account name in `deployments/dev/terraform.tfvars`:

1. Open `deployments/dev/terraform.tfvars`
2. Change `storage_account_name = "storagemoduledev001"` to something unique
3. Storage account names must be globally unique across all of Azure
4. Use lowercase letters and numbers only, 3-24 characters
5. Example: `storage_account_name = "mystorageacct$(Get-Random)"`

## Troubleshooting

### Common Issues:

1. **"Storage account name already exists"**
   - Change the `storage_account_name` in `terraform.tfvars` to something unique

2. **"Insufficient permissions"**
   - Ensure the Service Principal has Contributor role on the subscription
   - Check the subscription ID is correct

3. **"Backend initialization failed"**
   - Verify the storage account name in GitHub secrets
   - Ensure the storage account exists and is accessible

4. **"Authentication failed"**
   - Verify the `AZURE_CREDENTIALS` secret is valid JSON
   - Check that the Service Principal hasn't expired

## Next Steps

Once authentication is set up:
1. Commit and push your changes
2. The GitHub Action will automatically run
3. Check the Actions tab for deployment status
4. Review the Terraform plan in PR comments
5. Merge to main branch to apply changes

## Security Best Practices

- [âœ“] Use Service Principals (not personal accounts)
- [âœ“] Grant minimum required permissions
- [âœ“] Store secrets in GitHub Secrets (never in code)
- [âœ“] Use environment protection rules for production
- [âœ“] Regularly rotate Service Principal secrets
- [âœ“] Monitor Service Principal usage in Azure AD
