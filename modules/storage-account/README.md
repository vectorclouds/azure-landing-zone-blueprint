# Azure Storage Account Module

This Terraform module creates an Azure Storage Account with enterprise-grade security configurations, network controls, and optional features like private endpoints, customer-managed encryption, and resource locks.

## Features

- **Security First**: HTTPS-only traffic, minimum TLS 1.2, configurable public access controls
- **Network Controls**: Network rules, private endpoints, subnet restrictions
- **Advanced Features**: Customer-managed encryption, managed identity, blob properties
- **Compliance Ready**: Resource locks, audit logging, advanced threat protection
- **Container Management**: Automated container creation with access controls
- **Comprehensive Outputs**: All necessary connection strings, endpoints, and metadata

## Usage

### Basic Storage Account

```hcl
module "storage_account" {
  source = "./modules/storage-account/terraform"
  
  storage_account_name = "mystorageaccount001"
  resource_group_name  = "my-resource-group"
  location            = "East US"
  environment         = "prod"
  
  # Basic configuration
  account_tier         = "Standard"
  replication_type     = "LRS"
  access_tier         = "Hot"
  
  common_tags = {
    Project     = "MyProject"
    Owner       = "Platform Team"
    CostCenter  = "IT-001"
  }
}
```

### Enterprise Storage Account with Security Features

```hcl
module "secure_storage_account" {
  source = "./modules/storage-account/terraform"
  
  storage_account_name = "securestorage001"
  resource_group_name  = "security-rg"
  location            = "East US"
  environment         = "prod"
  purpose             = "Secure document storage"
  
  # Storage configuration
  account_tier     = "Standard"
  replication_type = "GRS"
  account_kind     = "StorageV2"
  access_tier      = "Cool"
  
  # Security settings
  https_traffic_only_enabled           = true
  min_tls_version                     = "TLS1_2"
  allow_nested_items_to_be_public     = false
  shared_access_key_enabled           = false
  public_network_access_enabled       = false
  default_to_oauth_authentication     = true
  
  # Network rules
  enable_network_rules        = true
  network_rules_default_action = "Deny"
  network_rules_bypass        = ["AzureServices", "Logging", "Metrics"]
  allowed_ip_ranges          = ["203.0.113.0/24"]
  allowed_subnet_ids         = ["/subscriptions/.../subnets/app-subnet"]
  
  # Blob properties and retention
  enable_blob_service_properties = true
  blob_versioning_enabled       = true
  blob_change_feed_enabled      = true
  blob_delete_retention_days    = 30
  container_delete_retention_days = 30
  blob_last_access_time_enabled = true
  
  # Managed identity
  identity_type = "SystemAssigned"
  
  # Resource protection
  enable_resource_lock = true
  lock_level          = "CanNotDelete"
  
  # Containers
  containers = {
    "documents" = {
      access_type = "private"
    }
    "logs" = {
      access_type = "private"
    }
  }
  
  common_tags = {
    Environment   = "prod"
    Classification = "confidential"
    Compliance    = "required"
  }
}
```

### Storage Account with Private Endpoint

```hcl
module "private_storage_account" {
  source = "./modules/storage-account/terraform"
  
  storage_account_name = "privatestorage001"
  resource_group_name  = "network-rg"
  location            = "East US"
  environment         = "prod"
  
  # Disable public access
  public_network_access_enabled = false
  
  # Enable private endpoint
  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/.../subnets/private-endpoint-subnet"
  private_dns_zone_ids      = ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"]
  
  # Network rules for additional security
  enable_network_rules         = true
  network_rules_default_action = "Deny"
  
  common_tags = {
    NetworkTier = "private"
    Security    = "high"
  }
}
```

### Storage Account with Customer-Managed Encryption

```hcl
module "encrypted_storage_account" {
  source = "./modules/storage-account/terraform"
  
  storage_account_name = "encryptedstorage001"
  resource_group_name  = "crypto-rg"
  location            = "East US"
  environment         = "prod"
  
  # Managed identity for encryption
  identity_type = "UserAssigned"
  identity_ids  = ["/subscriptions/.../userAssignedIdentities/storage-identity"]
  
  # Customer-managed encryption
  customer_managed_key_vault_key_id             = "/subscriptions/.../keys/storage-key"
  customer_managed_key_user_assigned_identity_id = "/subscriptions/.../userAssignedIdentities/storage-identity"
  
  common_tags = {
    Encryption = "customer-managed"
    Compliance = "required"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_blob_service.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_blob_service) | resource |
| [azurerm_private_endpoint.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_management_lock.storage_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_storage_container.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| storage_account_name | Name of the storage account. Must be globally unique and between 3-24 characters. | `string` | n/a | yes |
| resource_group_name | Name of the resource group where the storage account will be created. | `string` | n/a | yes |
| location | Azure region where the storage account will be created. | `string` | n/a | yes |
| environment | Environment name (e.g., dev, test, prod). | `string` | n/a | yes |
| account_tier | Performance tier of the storage account. Valid options are Standard and Premium. | `string` | `"Standard"` | no |
| replication_type | Type of replication for the storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS. | `string` | `"LRS"` | no |
| account_kind | Kind of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2. | `string` | `"StorageV2"` | no |
| access_tier | Access tier for the storage account. Valid options are Hot, Cool. | `string` | `"Hot"` | no |
| https_traffic_only_enabled | Boolean flag which forces HTTPS if enabled. | `bool` | `true` | no |
| min_tls_version | Minimum TLS version for the storage account. Valid options are TLS1_0, TLS1_1, TLS1_2. | `string` | `"TLS1_2"` | no |
| allow_nested_items_to_be_public | Allow or disallow nested items within this Account to opt into being public. | `bool` | `false` | no |
| shared_access_key_enabled | Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. | `bool` | `true` | no |
| public_network_access_enabled | Whether the public network access is enabled. | `bool` | `true` | no |
| enable_private_endpoint | Whether to enable private endpoint for the storage account. | `bool` | `false` | no |
| enable_resource_lock | Whether to enable resource lock for the storage account. | `bool` | `false` | no |
| containers | Map of containers to create in the storage account. | `map(object({access_type = string}))` | `{}` | no |
| common_tags | Common tags to be applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | The ID of the storage account. |
| storage_account_name | The name of the storage account. |
| primary_blob_endpoint | The endpoint URL for blob storage in the primary location. |
| primary_connection_string | The connection string associated with the primary location. (sensitive) |
| primary_access_key | The primary access key for the storage account. (sensitive) |
| principal_id | The Principal ID associated with this Managed Service Identity. |
| private_endpoint_id | The ID of the private endpoint. |
| container_ids | Map of container names to their IDs. |

## Security Considerations

1. **Access Keys**: By default, shared access key authentication is enabled. For enhanced security, consider setting `shared_access_key_enabled = false` and use Azure AD authentication.

2. **Network Access**: The module defaults to allowing public network access. For production workloads, consider:
   - Setting `public_network_access_enabled = false`
   - Enabling private endpoints
   - Configuring network rules to restrict access

3. **TLS Version**: The module enforces TLS 1.2 by default. Avoid downgrading unless absolutely necessary.

4. **Resource Locks**: Enable resource locks in production to prevent accidental deletion.

5. **Encryption**: The module supports customer-managed encryption keys for enhanced security compliance.

## Examples

See the `examples/` directory for complete implementation examples including:
- Basic storage account setup
- Enterprise security configuration
- Private endpoint integration
- Multi-container scenarios

## Contributing

When contributing to this module, please:
1. Follow Terraform best practices
2. Update documentation for any new variables or outputs
3. Test your changes with multiple scenarios
4. Ensure security configurations remain secure by default

## License

This module is licensed under the Apache License 2.0. See LICENSE file for details.