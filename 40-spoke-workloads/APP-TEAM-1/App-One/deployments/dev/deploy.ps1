#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy Storage Account Module locally to Azure

.DESCRIPTION
    This script helps deploy the storage account module locally with proper setup and verification.

.PARAMETER StorageAccountName
    Unique name for the storage account (optional, will prompt if not provided)

.PARAMETER SkipLogin
    Skip Azure login (use if already logged in)

.PARAMETER AutoApprove
    Skip interactive approval for terraform apply

.EXAMPLE
    .\deploy.ps1 -StorageAccountName "mystorageacct001"

.EXAMPLE
    .\deploy.ps1 -SkipLogin -AutoApprove
#>

param(
    [string]$StorageAccountName,
    [switch]$SkipLogin,
    [switch]$AutoApprove
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Color = @{
    Green  = "Green"
    Yellow = "Yellow"
    Red    = "Red"
    Cyan   = "Cyan"
}

function Write-Status {
    param([string]$Message, [string]$Color = "White")
    Write-Host "[START] $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor $Color.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor $Color.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Color.Red
}

# Check if we're in the right directory
if (-not (Test-Path "terraform.tfvars")) {
    Write-Error "terraform.tfvars not found. Please run this script from the deployments/dev directory."
    Write-Host "Expected path: azure-landing-zone-blueprint/deployments/dev" -ForegroundColor $Color.Yellow
    exit 1
}

Write-Status "Azure Storage Account Module Deployment" $Color.Cyan
Write-Host "=" * 50

# Step 1: Check Prerequisites
Write-Status "Checking prerequisites..."

# Check Terraform
try {
    $tfVersion = terraform --version | Select-String "Terraform" | ForEach-Object { $_.ToString().Split(' ')[1] }
    Write-Success "Terraform found: $tfVersion"
} catch {
    Write-Error "Terraform not found. Please install Terraform >= 1.13.3"
    exit 1
}

# Check Azure CLI
try {
    $azVersion = az --version | Select-String "azure-cli" | ForEach-Object { $_.ToString().Split(' ')[-1] }
    Write-Success "Azure CLI found: $azVersion"
} catch {
    Write-Error "Azure CLI not found. Please install Azure CLI"
    exit 1
}

# Step 2: Azure Login
if (-not $SkipLogin) {
    Write-Status "Checking Azure authentication..."
    try {
        $account = az account show --query "name" -o tsv 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Already logged in to Azure: $account"
            $loginChoice = Read-Host "Continue with current account? (y/n)"
            if ($loginChoice -ne 'y' -and $loginChoice -ne 'Y') {
                az login
            }
        } else {
            Write-Status "Logging in to Azure..."
            az login
        }
    } catch {
        Write-Status "Logging in to Azure..."
        az login
    }
    
    # Set subscription
    Write-Status "Setting Azure subscription..."
    az account set --subscription "{subscription-id}"
    Write-Success "Subscription set to: {subscription-id}"
}

# Step 3: Storage Account Name
if (-not $StorageAccountName) {
    Write-Status "Storage Account Configuration"
    Write-Host "Storage account names must be:"
    Write-Host "- Globally unique across all of Azure"
    Write-Host "- 3-24 characters long"
    Write-Host "- Only lowercase letters and numbers"
    Write-Host ""
    
    # Generate a suggestion
    $randomSuffix = Get-Random -Minimum 1000 -Maximum 9999
    $suggestion = "storagemoduledev$randomSuffix"
    
    $StorageAccountName = Read-Host "Enter storage account name [$suggestion]"
    if (-not $StorageAccountName) {
        $StorageAccountName = $suggestion
    }
}

# Validate storage account name
if ($StorageAccountName -notmatch '^[a-z0-9]{3,24}$') {
    Write-Error "Invalid storage account name. Must be 3-24 characters, lowercase letters and numbers only."
    exit 1
}

Write-Success "Using storage account name: $StorageAccountName"

# Step 4: Update terraform.tfvars
Write-Status "Updating terraform.tfvars..."
$tfvarsContent = Get-Content "terraform.tfvars" -Raw
$tfvarsContent = $tfvarsContent -replace 'storage_account_name = ".*"', "storage_account_name = `"$StorageAccountName`""
Set-Content "terraform.tfvars" -Value $tfvarsContent
Write-Success "Updated terraform.tfvars with storage account name"

# Step 5: Terraform Operations
Write-Status "Initializing Terraform..."
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform init failed"
    exit 1
}
Write-Success "Terraform initialized"

Write-Status "Validating Terraform configuration..."
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform validation failed"
    exit 1
}
Write-Success "Terraform configuration is valid"

Write-Status "Planning Terraform deployment..."
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform plan failed"
    exit 1
}
Write-Success "Terraform plan completed"

# Step 6: Apply
if ($AutoApprove) {
    Write-Status "Applying Terraform configuration (auto-approved)..."
    terraform apply tfplan
} else {
    Write-Status "Ready to deploy!"
    Write-Host ""
    Write-Host "Review the plan above. This will create:" -ForegroundColor $Color.Yellow
    Write-Host "- Resource Group: rg-storage-module-dev" -ForegroundColor $Color.Yellow
    Write-Host "- Storage Account: $StorageAccountName" -ForegroundColor $Color.Yellow
    Write-Host "- Storage Containers as configured" -ForegroundColor $Color.Yellow
    Write-Host ""
    
    $confirm = Read-Host "Do you want to apply these changes? (yes/no)"
    if ($confirm -eq 'yes' -or $confirm -eq 'y') {
        Write-Status "Applying Terraform configuration..."
        terraform apply tfplan
    } else {
        Write-Warning "Deployment cancelled by user"
        exit 0
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform apply failed"
    exit 1
}

# Step 7: Success
Write-Success "Deployment completed successfully! [SUCCESS]"
Write-Host ""
Write-Host "[SUMMARY] Deployment Summary:" -ForegroundColor $Color.Cyan
Write-Host "=" * 30

try {
    $resourceGroupName = terraform output -raw resource_group_name
    $storageAccountId = terraform output -raw storage_account_id
    $blobEndpoint = terraform output -raw primary_blob_endpoint
    $moduleVersion = terraform output -raw module_version
    
    Write-Host "Resource Group: $resourceGroupName" -ForegroundColor $Color.Green
    Write-Host "Storage Account: $StorageAccountName" -ForegroundColor $Color.Green
    Write-Host "Blob Endpoint: $blobEndpoint" -ForegroundColor $Color.Green
    Write-Host "Module Version: $moduleVersion" -ForegroundColor $Color.Green
} catch {
    Write-Warning "Could not retrieve all outputs. Check with 'terraform output'"
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor $Color.Cyan
Write-Host "- View your resources in the Azure Portal"
Write-Host "- Test uploading files to the storage account"
Write-Host "- Check the automatic tags applied to resources"
Write-Host "- Run 'terraform output' to see all output values"
Write-Host ""
Write-Host "To clean up: terraform destroy" -ForegroundColor $Color.Yellow
Write-Host ""

# Clean up plan file
Remove-Item -Path "tfplan" -ErrorAction SilentlyContinue
