# Required Variables
variable "storage_account_name" {
  description = "Name of the storage account. Must be globally unique and between 3-24 characters."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3-24 characters and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be created."
  type        = string
}

# Storage Account Configuration
variable "account_tier" {
  description = "Performance tier of the storage account. Valid options are Standard and Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "replication_type" {
  description = "Type of replication for the storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Kind of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "access_tier" {
  description = "Access tier for the storage account. Valid options are Hot, Cool."
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either 'Hot' or 'Cool'."
  }
}

# Security Configuration
variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for the storage account. Valid options are TLS1_0, TLS1_1, TLS1_2."
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled."
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "Default to Azure Active Directory authorization in the Azure portal when accessing the storage account."
  type        = bool
  default     = false
}

# Network Rules Configuration
variable "enable_network_rules" {
  description = "Whether to enable network rules for the storage account."
  type        = bool
  default     = false
}

variable "network_rules_default_action" {
  description = "Default action when no network rule matches. Valid options are Allow, Deny."
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "Network rules default action must be either 'Allow' or 'Deny'."
  }
}

variable "network_rules_bypass" {
  description = "List of services that are allowed to bypass the network rules."
  type        = list(string)
  default     = ["AzureServices"]
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges that are allowed to access the storage account."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs that are allowed to access the storage account."
  type        = list(string)
  default     = []
}

# Blob Properties Configuration
variable "enable_advanced_threat_protection" {
  description = "Whether to enable advanced threat protection for the storage account."
  type        = bool
  default     = false
}

variable "enable_blob_service_properties" {
  description = "Whether to enable blob service properties configuration."
  type        = bool
  default     = false
}

variable "blob_versioning_enabled" {
  description = "Whether versioning is enabled for blobs."
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "Whether change feed is enabled for blobs."
  type        = bool
  default     = false
}

variable "blob_delete_retention_days" {
  description = "Number of days to retain deleted blobs."
  type        = number
  default     = 7
  validation {
    condition     = var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365
    error_message = "Blob delete retention days must be between 1 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Number of days to retain deleted containers."
  type        = number
  default     = 7
  validation {
    condition     = var.container_delete_retention_days >= 1 && var.container_delete_retention_days <= 365
    error_message = "Container delete retention days must be between 1 and 365."
  }
}

variable "blob_default_service_version" {
  description = "Default service version for blob service."
  type        = string
  default     = null
}

variable "blob_last_access_time_enabled" {
  description = "Whether last access time based tracking is enabled for blobs."
  type        = bool
  default     = false
}

variable "cors_rules" {
  description = "CORS rules for the storage account."
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

# Identity Configuration
variable "identity_type" {
  description = "Type of managed identity for the storage account. Valid options are SystemAssigned, UserAssigned, SystemAssigned,UserAssigned."
  type        = string
  default     = null
  validation {
    condition = var.identity_type == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, 'SystemAssigned, UserAssigned', or null."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs for the storage account."
  type        = list(string)
  default     = []
}

# Customer-Managed Encryption
variable "customer_managed_key_vault_key_id" {
  description = "The ID of the Key Vault Key to use for customer-managed encryption."
  type        = string
  default     = null
}

variable "customer_managed_key_user_assigned_identity_id" {
  description = "The ID of the user assigned identity to use for customer-managed encryption."
  type        = string
  default     = null
}

# Private Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Whether to enable private endpoint for the storage account."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint."
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for the private endpoint."
  type        = list(string)
  default     = null
}

# Resource Lock Configuration
variable "enable_resource_lock" {
  description = "Whether to enable resource lock for the storage account."
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "Level of the resource lock. Valid options are CanNotDelete, ReadOnly."
  type        = string
  default     = "CanNotDelete"
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level must be either 'CanNotDelete' or 'ReadOnly'."
  }
}

# Storage Containers Configuration
variable "containers" {
  description = "Map of containers to create in the storage account."
  type = map(object({
    access_type = string
  }))
  default = {}
}

# Tagging
variable "environment" {
  description = "Environment name (e.g., dev, test, prod)."
  type        = string
}

variable "purpose" {
  description = "Purpose or description of the storage account."
  type        = string
  default     = "General purpose storage account"
}

variable "enable_module_tags" {
  description = "Whether to enable automatic module tagging with version and metadata information."
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "storage_tags" {
  description = "Additional tags specific to the storage account."
  type        = map(string)
  default     = {}
}