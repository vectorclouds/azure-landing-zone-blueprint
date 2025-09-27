# [SECURITY] Secure Development Workflow

This guide explains how to work securely with this public repository while keeping your sensitive information private.

## [TARGET] Security Approach

This repository uses a **template-based approach** where:
- [✓] **Public**: Template files with placeholders (`*.example`, `*.template`)
- [✓] **Public**: Documentation and code
- [X] **Private**: Your actual configuration files with real values
- [X] **Private**: Sensitive data (subscription IDs, resource names, etc.)

## [START] Quick Setup (New Device/Clone)

### Method 1: Using terraform.tfvars (Recommended)

```powershell
# 1. Clone the repository
git clone https://github.com/vectorclouds/azure-landing-zone-blueprint.git
cd azure-landing-zone-blueprint/deployments/dev

# 2. Create your private config from template
cp terraform.tfvars.example terraform.tfvars

# 3. Edit terraform.tfvars with your actual values
# - Your Azure subscription ID
# - Unique storage account name
# - Your preferred resource names

# 4. Deploy normally
terraform init
terraform plan
terraform apply
```

### Method 2: Using Environment Variables (Advanced)

```powershell
# 1. Clone the repository  
git clone https://github.com/vectorclouds/azure-landing-zone-blueprint.git
cd azure-landing-zone-blueprint/deployments/dev

# 2. Create your private environment file
cp .env.example .env

# 3. Edit .env with your actual values

# 4. Load environment variables
. .\load-env.ps1

# 5. Use environment-based config
terraform plan -var="subscription_id=$env:AZURE_SUBSCRIPTION_ID" -var="storage_account_name=$env:STORAGE_ACCOUNT_NAME"
```

## [FOLDER] File Security Structure

```
deployments/dev/
├── terraform.tfvars.example    [✓] Public template
├── terraform.tfvars           [X] Private (your actual values)
├── .env.example               [✓] Public template  
├── .env                       [X] Private (your actual values)
├── main.tf                    [✓] Public (no sensitive data)
├── variables.tf               [✓] Public (no sensitive data)
└── outputs.tf                 [✓] Public (no sensitive data)
```

## [LOCK] What's Protected by .gitignore

The following files are automatically excluded from git:

```gitignore
# Your private configuration files
terraform.tfvars
*.tfvars
.env
*.tfstate*
*.tfplan

# Backend configuration
backend-config.hcl
backend.hcl

# Secrets and keys
secrets/
private/
*.key
*.pem
```

## [WORKFLOW] Working Across Multiple Devices

### Option A: Secure Cloud Storage (Recommended)
Store your private configs in a secure location:

```powershell
# Save your configs securely
# - Use a private cloud storage (OneDrive, Google Drive, etc.)
# - Store in a password manager as secure notes
# - Use Azure Key Vault for enterprise scenarios

# When setting up a new device:
# 1. Clone the repo
# 2. Download your private configs from secure storage
# 3. Place them in the correct locations
```

### Option B: Environment Variables Only
```powershell
# Store only environment variables securely
# Create .env file on each device manually
# Never commit .env to any repository
```

### Option C: Personal Private Repository
```powershell
# Create a separate private repo for your configs
# Keep only the *.tfvars and .env files there
# Clone both repositories when needed
```

## 🚨 Security Checklist

Before making any commits:

- [ ] [✓] Run `git status` to check what will be committed
- [ ] [✓] Verify no `*.tfvars` files are staged
- [ ] [✓] Verify no `.env` files are staged  
- [ ] [✓] Check that `.gitignore` is working correctly
- [ ] [✓] No subscription IDs or resource names in committed files
- [ ] [✓] No passwords, keys, or secrets in committed files

### Quick Security Verification
```powershell
# Check what would be committed
git status

# Search for potential sensitive data (should return nothing)
git grep -i "subscription.*id"
git grep -i "aa0beb1d"  # Your subscription ID
git grep -i "password\|secret\|key"

# Verify .gitignore is working
echo "test sensitive data" > terraform.tfvars
git status  # Should show terraform.tfvars as ignored
rm terraform.tfvars
```

## [CONFIG] Local Development Commands

```powershell
# Standard workflow with terraform.tfvars
terraform init
terraform plan
terraform apply

# Workflow with environment variables
. .\load-env.ps1
terraform plan -var="subscription_id=$env:AZURE_SUBSCRIPTION_ID"
terraform apply -auto-approve

# Check what would be deployed without applying
terraform plan -out=tfplan
terraform show tfplan
```

## 🚫 What NOT to Do

- [X] Never commit `terraform.tfvars` with real values
- [X] Never commit `.env` files
- [X] Never put subscription IDs in template files
- [X] Never commit state files (`*.tfstate`)
- [X] Never put secrets in any committed file
- [X] Never disable `.gitignore` for convenience

## [✓] What TO Do

- [✓] Always use template files for public sharing
- [✓] Keep real values in ignored files only
- [✓] Use meaningful placeholder values in templates
- [✓] Document the secure workflow clearly
- [✓] Regularly audit what's being committed
- [✓] Use environment variables for CI/CD

## 🆘 If You Accidentally Commit Sensitive Data

```powershell
# 1. Remove from current commit (if not pushed yet)
git reset --soft HEAD~1
git reset HEAD terraform.tfvars
git commit -m "Your commit message"

# 2. If already pushed, remove from history (DANGER!)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch terraform.tfvars' \
  --prune-empty --tag-name-filter cat -- --all

# 3. Force push (breaks history for collaborators!)
git push origin --force --all

# 4. Consider the sensitive data compromised:
# - Rotate any exposed secrets
# - Change subscription IDs if possible
# - Review access logs
```

## [TARGET] Repository Showcase Best Practices

For public showcase repositories:

1. **Clear Documentation**: Explain the security approach
2. **Working Examples**: Use placeholder values that clearly work
3. **Easy Setup**: Provide simple copy-and-edit instructions  
4. **Security Focus**: Highlight security considerations
5. **Professional**: Show enterprise-grade practices

This approach allows you to showcase your Infrastructure as Code skills while maintaining proper security practices!