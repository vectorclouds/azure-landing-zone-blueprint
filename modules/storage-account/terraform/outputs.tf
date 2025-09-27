# Storage Account Outputs

output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.main.name
}

output "primary_location" {
  description = "The primary location of the storage account."
  value       = azurerm_storage_account.main.primary_location
}

output "secondary_location" {
  description = "The secondary location of the storage account."
  value       = azurerm_storage_account.main.secondary_location
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "The endpoint URL for DFS storage in the primary location."
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "primary_web_endpoint" {
  description = "The endpoint URL for web storage in the primary location."
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "secondary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_blob_endpoint
}

output "secondary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_queue_endpoint
}

output "secondary_table_endpoint" {
  description = "The endpoint URL for table storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_table_endpoint
}

output "secondary_file_endpoint" {
  description = "The endpoint URL for file storage in the secondary location."
  value       = azurerm_storage_account.main.secondary_file_endpoint
}

# Access Keys and Connection Strings (sensitive)
output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account."
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary location."
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The connection string associated with the secondary location."
  value       = azurerm_storage_account.main.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "The connection string associated with the primary blob location."
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "The connection string associated with the secondary blob location."
  value       = azurerm_storage_account.main.secondary_blob_connection_string
  sensitive   = true
}

# Identity Outputs
output "identity" {
  description = "The identity block of the storage account."
  value       = azurerm_storage_account.main.identity
}

output "principal_id" {
  description = "The Principal ID associated with this Managed Service Identity."
  value       = try(azurerm_storage_account.main.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The Tenant ID associated with this Managed Service Identity."
  value       = try(azurerm_storage_account.main.identity[0].tenant_id, null)
}

# Private Endpoint Outputs
output "private_endpoint_id" {
  description = "The ID of the private endpoint."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].id : null
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].private_service_connection[0].private_ip_address : null
}

# Container Outputs
output "container_ids" {
  description = "Map of container names to their IDs."
  value       = { for k, v in azurerm_storage_container.containers : k => v.id }
}

output "container_urls" {
  description = "Map of container names to their URLs."
  value       = { for k, v in azurerm_storage_container.containers : k => "${azurerm_storage_account.main.primary_blob_endpoint}${k}" }
}

# Resource Lock Output
output "resource_lock_id" {
  description = "The ID of the resource lock."
  value       = var.enable_resource_lock ? azurerm_management_lock.storage_lock[0].id : null
}

# Module Version Information
output "module_version" {
  description = "The version of the storage account module."
  value       = local.artifact_data.version
}

output "module_name" {
  description = "The name of the storage account module."
  value       = local.artifact_data.name
}