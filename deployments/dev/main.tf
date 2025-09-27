# Configure Terraform providers and backend
terraform {
  required_version = ">= 1.13.3"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.46.0"
    }
  }
  
  # Backend configuration for storing Terraform state
  # This will be configured via backend config file or environment variables
  backend "azurerm" {
    # These values will be provided via backend config or environment variables
    # resource_group_name  = "rg-terraform-state"
    # storage_account_name = "tfstateXXXXXX"
    # container_name      = "tfstate"
    # key                 = "dev/storage-module.tfstate"
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Subscription ID
  subscription_id = var.subscription_id
}

# Data source to get current Azure configuration
data "azurerm_client_config" "current" {}

# Create resource group for the storage account
resource "azurerm_resource_group" "storage_demo" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Purpose     = "Storage Account Module Demo"
  }
}

# Deploy the storage account module
module "demo_storage_account" {
  source = "../../modules/storage-account/terraform"
  
  # Required variables
  storage_account_name = var.storage_account_name
  resource_group_name  = azurerm_resource_group.storage_demo.name
  location            = azurerm_resource_group.storage_demo.location
  environment         = var.environment
  
  # Configuration
  account_tier     = var.account_tier
  replication_type = var.replication_type
  access_tier      = var.access_tier
  
  # Security settings
  https_traffic_only_enabled           = var.https_traffic_only_enabled
  min_tls_version                     = var.min_tls_version
  allow_nested_items_to_be_public     = var.allow_nested_items_to_be_public
  shared_access_key_enabled           = var.shared_access_key_enabled
  public_network_access_enabled       = var.public_network_access_enabled
  
  # Containers to create
  containers = var.containers
  
  # Tagging
  common_tags = {
    Project     = var.project_name
    Owner       = var.owner
    Environment = var.environment
    DeployedBy  = "Terraform"
    DeployedOn  = timestamp()
  }
  
  storage_tags = var.storage_tags
}