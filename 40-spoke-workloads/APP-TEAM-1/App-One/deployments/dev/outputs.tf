# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.storage_demo.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.storage_demo.id
}

# Storage Account Outputs
output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.demo_storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.demo_storage_account.storage_account_name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.demo_storage_account.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = module.demo_storage_account.primary_connection_string
  sensitive   = true
}

output "module_version" {
  description = "Version of the storage account module used"
  value       = module.demo_storage_account.module_version
}

output "container_urls" {
  description = "URLs of the created containers"
  value       = module.demo_storage_account.container_urls
}

# Deployment Information
output "deployment_info" {
  description = "Information about this deployment"
  value = {
    subscription_id     = var.subscription_id
    location           = var.location
    environment        = var.environment
    project_name       = var.project_name
    deployed_at        = timestamp()
  }
}