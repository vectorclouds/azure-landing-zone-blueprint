# Azure Configuration
variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed"
  type        = string
  sensitive   = true
}

# Resource Group Configuration
variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

# Project Information
variable "project_name" {
  description = "Name of the project for tagging purposes"
  type        = string
  default     = "Storage Module Demo"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the resources for tagging purposes"
  type        = string
  default     = "Platform Team"
}

# Storage Account Configuration
variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, 3-24 characters, lowercase letters and numbers only)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3-24 characters and contain only lowercase letters and numbers."
  }
}

variable "account_tier" {
  description = "Performance tier of the storage account"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "replication_type" {
  description = "Type of replication for the storage account"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "access_tier" {
  description = "Access tier for the storage account"
  type        = string
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be either 'Hot' or 'Cool'."
  }
}

# Security Configuration
variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items within this Account to opt into being public"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled"
  type        = bool
  default     = true
}

# Container Configuration
variable "containers" {
  description = "Map of containers to create in the storage account"
  type = map(object({
    access_type = string
  }))
  default = {
    "demo-container" = {
      access_type = "private"
    }
  }
}

# Additional Tags
variable "storage_tags" {
  description = "Additional tags specific to the storage account"
  type        = map(string)
  default = {
    Purpose = "Demo deployment of storage account module"
  }
}