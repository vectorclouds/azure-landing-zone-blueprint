# Storage Account Module Usage Example
# This file demonstrates how to use the storage account module within the Azure Landing Zone Blueprint

# Example 1: Basic Storage Account for Development
module "dev_storage" {
  source = "../../modules/storage-account/terraform"
  
  storage_account_name = "devstorageaccount001"
  resource_group_name  = "rg-dev-storage"
  location            = "East US"
  environment         = "dev"
  purpose             = "Development environment storage"
  
  # Development-friendly settings
  account_tier     = "Standard"
  replication_type = "LRS"
  access_tier      = "Hot"
  
  # Allow public access for development
  public_network_access_enabled = true
  shared_access_key_enabled     = true
  
  # Basic containers
  containers = {
    "dev-uploads" = {
      access_type = "private"
    }
    "dev-static" = {
      access_type = "blob"
    }
  }
  
  common_tags = {
    Environment = "dev"
    Purpose     = "development"
    Owner       = "dev-team"
  }
}

# Example 2: Production Storage Account with Enterprise Security
module "prod_storage" {
  source = "../../modules/storage-account/terraform"
  
  storage_account_name = "prodstorage001"
  resource_group_name  = "rg-prod-storage"
  location            = "East US"
  environment         = "prod"
  purpose             = "Production application storage"
  
  # Production-grade settings
  account_tier     = "Standard"
  replication_type = "GRS"
  account_kind     = "StorageV2"
  access_tier      = "Hot"
  
  # Enhanced security for production
  https_traffic_only_enabled           = true
  min_tls_version                     = "TLS1_2"
  allow_nested_items_to_be_public     = false
  shared_access_key_enabled           = false
  public_network_access_enabled       = false
  default_to_oauth_authentication     = true
  
  # Network restrictions
  enable_network_rules         = true
  network_rules_default_action = "Deny"
  network_rules_bypass        = ["AzureServices"]
  
  # Advanced blob features
  enable_blob_service_properties = true
  blob_versioning_enabled       = true
  blob_change_feed_enabled      = true
  blob_delete_retention_days    = 30
  container_delete_retention_days = 30
  
  # Managed identity
  identity_type = "SystemAssigned"
  
  # Resource protection
  enable_resource_lock = true
  lock_level          = "CanNotDelete"
  
  # Production containers
  containers = {
    "app-data" = {
      access_type = "private"
    }
    "backups" = {
      access_type = "private"
    }
    "logs" = {
      access_type = "private"
    }
  }
  
  common_tags = {
    Environment    = "prod"
    CriticalSystem = "yes"
    BackupRequired = "yes"
    Owner         = "platform-team"
  }
}

# Example 3: Storage Account with Private Endpoint
module "private_storage" {
  source = "../../modules/storage-account/terraform"
  
  storage_account_name = "privatestorage001"
  resource_group_name  = "rg-private-storage"
  location            = "East US"
  environment         = "prod"
  purpose             = "Private network storage"
  
  # Disable public access completely
  public_network_access_enabled = false
  
  # Enable private endpoint
  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/{subscription-id}/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/subnet-private-endpoints"
  private_dns_zone_ids      = ["/subscriptions/{subscription-id}/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
  
  # Strict network rules
  enable_network_rules         = true
  network_rules_default_action = "Deny"
  
  common_tags = {
    NetworkTier = "private"
    Security    = "high"
    Environment = "prod"
  }
}

# Outputs for reference
output "dev_storage_info" {
  value = {
    name                = module.dev_storage.storage_account_name
    blob_endpoint       = module.dev_storage.primary_blob_endpoint
    container_urls      = module.dev_storage.container_urls
  }
}

output "prod_storage_info" {
  value = {
    name           = module.prod_storage.storage_account_name
    blob_endpoint  = module.prod_storage.primary_blob_endpoint
    principal_id   = module.prod_storage.principal_id
    container_urls = module.prod_storage.container_urls
  }
}

output "private_storage_info" {
  value = {
    name                    = module.private_storage.storage_account_name
    private_endpoint_id     = module.private_storage.private_endpoint_id
    private_endpoint_ip     = module.private_storage.private_endpoint_ip_address
  }
}