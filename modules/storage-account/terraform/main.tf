# Storage Account Resource
resource "azurerm_storage_account" "main" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  https_traffic_only_enabled      = var.https_traffic_only_enabled
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  default_to_oauth_authentication = var.default_to_oauth_authentication

  # Blob Properties Configuration
  dynamic "blob_properties" {
    for_each = var.enable_advanced_threat_protection ? [1] : []
    content {
      versioning_enabled       = var.blob_versioning_enabled
      change_feed_enabled      = var.blob_change_feed_enabled
      delete_retention_policy {
        days = var.blob_delete_retention_days
      }
      container_delete_retention_policy {
        days = var.container_delete_retention_days
      }
      dynamic "cors_rule" {
        for_each = var.cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }

  # Network Rules
  dynamic "network_rules" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action             = var.network_rules_default_action
      bypass                     = var.network_rules_bypass
      ip_rules                   = var.allowed_ip_ranges
      virtual_network_subnet_ids = var.allowed_subnet_ids
    }
  }

  # Identity configuration for system-assigned or user-assigned managed identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.identity_ids : null
    }
  }

  # Customer-managed encryption
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id          = var.customer_managed_key_vault_key_id
      user_assigned_identity_id = var.customer_managed_key_user_assigned_identity_id
    }
  }

  tags = local.all_tags
}

# Storage Account Blob Service (for advanced configurations)
resource "azurerm_storage_account_blob_service" "main" {
  count              = var.enable_blob_service_properties ? 1 : 0
  storage_account_id = azurerm_storage_account.main.id

  versioning_enabled       = var.blob_versioning_enabled
  change_feed_enabled      = var.blob_change_feed_enabled
  default_service_version  = var.blob_default_service_version
  last_access_time_enabled = var.blob_last_access_time_enabled

  cors_rule = var.cors_rules

  delete_retention_policy {
    days = var.blob_delete_retention_days
  }

  container_delete_retention_policy {
    days = var.container_delete_retention_days
  }
}

# Private Endpoint for Storage Account (optional)
resource "azurerm_private_endpoint" "storage_blob" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = merge(
    local.all_tags,
    {
      "Purpose" = "Private Endpoint for ${var.storage_account_name}"
    }
  )
}

# Resource Lock (optional)
resource "azurerm_management_lock" "storage_lock" {
  count      = var.enable_resource_lock ? 1 : 0
  name       = "${var.storage_account_name}-lock"
  scope      = azurerm_storage_account.main.id
  lock_level = var.lock_level
  notes      = "Terraform managed lock for storage account ${var.storage_account_name}"
}

# Storage Containers (optional)
resource "azurerm_storage_container" "containers" {
  for_each             = var.containers
  name                 = each.key
  storage_account_id   = azurerm_storage_account.main.id
  container_access_type = each.value.access_type
}
