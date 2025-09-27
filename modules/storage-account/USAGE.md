# Quick Usage Guide - Version Tracking

## What was implemented

✅ **artifact.json** - Centralized module metadata and version information
✅ **locals.tf** - Reads artifact.json and creates module tags automatically  
✅ **Automatic Tagging** - All Azure resources get tagged with module version info
✅ **Version Control** - Enable/disable module tagging with `enable_module_tags`
✅ **Python Script** - Helper script for version management

## Quick Example

```hcl
module "my_storage" {
  source = "./modules/storage-account/terraform"
  
  storage_account_name = "mystorageacct001"
  resource_group_name  = "my-rg"
  location            = "East US"
  environment         = "prod"
  
  # Version tagging enabled by default
  # enable_module_tags = true  # <- This is the default
}
```

**Result:** Your storage account will automatically have these tags:
```
Module.Name = "storage-account"
Module.Version = "0.0.1"  
Module.Type = "Azure Landing Zone Blueprint"
Environment = "prod"
Purpose = "General purpose storage account"
```

## Version Management Commands

```bash
# Bump patch version (0.0.1 -> 0.0.2)
python version_manager.py --bump patch

# Bump minor version (0.0.2 -> 0.1.0) 
python version_manager.py --bump minor

# Set specific version
python version_manager.py --version 1.0.0
```

## Files Created/Modified

- `artifact.json` - Simple module metadata (name, version, type, dates)
- `terraform/locals.tf` - Tag parsing and merging logic
- `terraform/variables.tf` - Added `enable_module_tags` variable
- `terraform/main.tf` - Updated to use consolidated tagging
- `terraform/outputs.tf` - Added module version outputs
- `version_manager.py` - Simple Python script for version management
- `README.md` - Updated with version tracking documentation

## Tag Precedence (highest to lowest)

1. `storage_tags` (user storage-specific tags)
2. `common_tags` (user common tags)  
3. Default tags (`Environment`, `Purpose`)
4. Module tags (`Module.*` - simple version info)

This ensures user tags always take precedence over automatic module tags.

## Benefits

🔍 **Audit Trail** - Know which module version created each resource
🐛 **Troubleshooting** - Quick module version identification  
📋 **Compliance** - Simple version tracking for governance
 **Resource Discovery** - Query resources by module version