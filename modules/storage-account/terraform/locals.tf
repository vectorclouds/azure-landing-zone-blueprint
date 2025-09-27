# Module Metadata and Version Information
locals {
  # Read the simplified artifact.json file
  artifact_data = jsondecode(file("${path.module}/../artifact.json"))
  
  # Create module tags that will be applied to all resources
  module_tags = var.enable_module_tags ? {
    "Module.Name"    = local.artifact_data.name
    "Module.Version" = local.artifact_data.version
    "Module.Type"    = local.artifact_data.type
  } : {}
  
  # Merge all tags together with proper precedence
  # Order of precedence: user storage_tags > user common_tags > default tags > module tags
  all_tags = merge(
    # Base module tags (lowest priority)
    local.module_tags,
    # Default environment and purpose tags
    {
      "Environment" = var.environment
      "Purpose"     = var.purpose
    },
    # User-provided common tags
    var.common_tags,
    # User-provided storage-specific tags (highest priority)
    var.storage_tags
  )
}