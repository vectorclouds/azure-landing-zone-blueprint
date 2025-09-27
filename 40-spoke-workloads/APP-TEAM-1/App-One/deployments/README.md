# Storage Account Module Deployment Guide

This guide walks you through deploying the storage account module to Azure using both local development and GitHub Actions CI/CD.

## 📁 Project Structure

```
azure-landing-zone-blueprint/
├── modules/storage-account/           # The reusable module
│   ├── terraform/                     # Module Terraform files
│   ├── artifact.json                  # Version tracking
│   └── examples/                      # Usage examples
├── deployments/                       # Deployment configurations
│   ├── dev/                          # Development environment
│   │   ├── main.tf                   # Main deployment config
│   │   ├── variables.tf              # Variable definitions
│   │   ├── outputs.tf                # Output definitions
│   │   └── terraform.tfvars          # Environment values
│   └── AUTHENTICATION_SETUP.md       # Azure auth setup guide
└── .github/workflows/                 # CI/CD pipelines
    └── deploy-storage-module.yml      # Terraform deployment workflow
```

## 🚀 Quick Start - Local Deployment

### Prerequisites
- Azure CLI installed and logged in
- Terraform >= 1.13.3 installed
- Azure subscription access

### 1. Clone and Navigate
```bash
git clone https://github.com/vectorclouds/azure-landing-zone-blueprint.git
cd azure-landing-zone-blueprint/deployments/dev
```

### 2. Create Your Configuration
```bash
# Copy the template to create your private config file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your actual values:
# - Your Azure subscription ID
# - Unique storage account name (globally unique)
# - Your resource group name and location
# - Project information and tags
```

### 3. Login to Azure
```bash
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### 4. Initialize and Deploy
```bash
# Initialize Terraform (first time only)
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

> **🔒 Security Note**: The `terraform.tfvars` file contains your sensitive information and is excluded from git by `.gitignore`. Only template files are committed to this public repository.

### 5. Verify Deployment
```bash
# Check outputs
terraform output

# Verify in Azure portal
az storage account show --name "youruniquestorageacct001" --resource-group "rg-storage-module-dev"
```

## 🔄 CI/CD Deployment with GitHub Actions

### Prerequisites
- GitHub repository with Admin access
- Azure subscription
- Service Principal configured (see AUTHENTICATION_SETUP.md)

### 1. Set Up Authentication
Follow the complete guide in `deployments/AUTHENTICATION_SETUP.md` to:
- Create Azure Service Principal
- Create Terraform state storage
- Configure GitHub secrets

### 2. Configure Deployment
Create your private configuration from the template:
```bash
# Copy template to create your private config
cp deployments/dev/terraform.tfvars.example deployments/dev/terraform.tfvars

# Edit terraform.tfvars with your specific values:
# - Your Azure subscription ID
# - Globally unique storage account name
# - Resource group name and location  
# - Project information and tags
```

> **⚠️ Important**: Never commit your actual `terraform.tfvars` file. It contains sensitive information and is excluded by `.gitignore`.

### 3. Deploy via GitHub Actions

#### Option A: Automatic Deployment
1. Commit your changes to a feature branch
2. Create a Pull Request to `main`
3. GitHub Actions will run `terraform plan` and comment on the PR
4. Review the plan in the PR comments
5. Merge the PR to `main` to trigger `terraform apply`

#### Option B: Manual Deployment
1. Go to GitHub Actions tab
2. Select "Deploy Storage Account Module" workflow
3. Click "Run workflow"
4. Choose branch and click "Run workflow"

### 4. Monitor Deployment
- Check the Actions tab for deployment status
- Review logs for any errors
- Verify resources in Azure portal

## 📊 Understanding the Deployment

### What Gets Created
1. **Resource Group**: `rg-storage-module-dev`
2. **Storage Account**: Your uniquely named storage account
3. **Containers**: Based on your `containers` configuration
4. **Tags**: Automatic module version tags + your custom tags

### Default Configuration
- **Tier**: Standard
- **Replication**: LRS (Locally Redundant Storage)
- **Access Tier**: Hot
- **Security**: HTTPS-only, TLS 1.2 minimum
- **Access**: Public network access enabled (change for production)

### Automatic Tags Applied
```json
{
  "Module.Name": "storage-account",
  "Module.Version": "0.0.1",
  "Module.Type": "Azure Landing Zone Blueprint",
  "Environment": "dev",
  "Purpose": "General purpose storage account",
  "Project": "Your Project Name",
  "Owner": "Your Team Name",
  "DeployedBy": "Terraform"
}
```

## 🔧 Customization Options

### Storage Configuration
Edit `terraform.tfvars` to customize:
```hcl
# Performance and redundancy
account_tier     = "Premium"      # Standard or Premium
replication_type = "GRS"         # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
access_tier      = "Cool"        # Hot or Cool

# Security settings
public_network_access_enabled = false  # Disable for production
shared_access_key_enabled     = false  # Use Azure AD only
```

### Container Configuration
```hcl
containers = {
  "documents" = {
    access_type = "private"
  }
  "public-files" = {
    access_type = "blob"         # public read access to blobs
  }
  "website" = {
    access_type = "container"    # public read access to container and blobs
  }
}
```

### Advanced Features
For advanced features like private endpoints, network rules, or customer-managed encryption, see the examples in `modules/storage-account/examples/`.

## 🧹 Cleanup

### Local Cleanup
```bash
cd deployments/dev
terraform destroy
```

### GitHub Actions Cleanup
1. Create a PR with the deletion of deployment files
2. Or manually run `terraform destroy` locally

## 🔍 Troubleshooting

### Common Issues

1. **Storage Account Name Already Exists**
   ```
   Error: storage account name "xyz" already exists
   ```
   **Solution**: Change `storage_account_name` in `terraform.tfvars` to something unique

2. **Authentication Failed**
   ```
   Error: building AzureRM Client: authentication failed
   ```
   **Solution**: Check Azure CLI login (`az account show`) or GitHub secrets

3. **Terraform State Lock**
   ```
   Error: state lock could not be acquired
   ```
   **Solution**: Wait for other operations to complete or force unlock if stuck

4. **Permission Denied**
   ```
   Error: insufficient privileges to complete the operation
   ```
   **Solution**: Ensure your account/service principal has Contributor role

### Debugging Commands
```bash
# Check Azure context
az account show

# Check Terraform state
terraform state list

# Check Azure resources
az resource list --resource-group "rg-storage-module-dev" --output table

# Check storage account
az storage account show --name "yourstorageaccount" --resource-group "rg-storage-module-dev"
```

## 📚 Next Steps

1. **Production Deployment**: Create `deployments/prod/` with production settings
2. **Security Hardening**: Enable private endpoints, disable public access
3. **Monitoring**: Add Azure Monitor alerts and logging
4. **Backup**: Configure backup policies for critical data
5. **Cost Optimization**: Review and optimize storage tiers

## � Security for Public Repositories

This repository is designed to be safely shared publicly while protecting your sensitive information:

### What's Protected
- ✅ Your subscription IDs, resource names, and configuration values
- ✅ Terraform state files and plans
- ✅ Environment variables and private keys
- ✅ Any sensitive deployment data

### How It Works
- **Template Files**: `*.example` and `*.template` files show structure with placeholder values
- **Private Files**: Your actual `terraform.tfvars` and `.env` files are excluded by `.gitignore`
- **Documentation**: Clear instructions for secure setup without exposing real values

### Quick Security Setup
```bash
# 1. Copy templates to create your private configs
cp terraform.tfvars.example terraform.tfvars
cp .env.example .env

# 2. Edit the files with your actual values
# 3. Verify security before committing
git status  # Should not show *.tfvars or .env files
```

📖 **Full Security Guide**: See `deployments/SECURE_WORKFLOW.md` for complete secure development practices.

## �📞 Support

- Check the module documentation in `modules/storage-account/README.md`
- Review examples in `modules/storage-account/examples/`
- Check GitHub Issues for common problems
- Review Azure documentation for storage account features