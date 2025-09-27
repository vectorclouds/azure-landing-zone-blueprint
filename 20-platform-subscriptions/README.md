WORK IN PROGRESS
# 20 - Platform Subscriptions

This folder contains the definition and Terraform code for creating platform subscriptions that provide shared services across your Azure Landing Zone.

## Platform Subscription Types

### Management Subscription
- **Purpose**: Centralized monitoring, logging, and management services
- **Services**: Log Analytics, Azure Monitor, Azure Security Center, Azure Automation
- **Management Group**: Platform > Management MG

### Connectivity Subscription
- **Purpose**: Network connectivity and hybrid connection services
- **Services**: Hub Virtual Networks, VPN Gateways, ExpressRoute, Azure Firewall, DNS
- **Management Group**: Platform > Connectivity MG

### Identity Subscription
- **Purpose**: Identity services and domain controllers
- **Services**: Azure AD Domain Services, Domain Controllers VMs, ADFS
- **Management Group**: Platform > Identity MG

### Shared Services Subscription (Optional)
- **Purpose**: Additional shared services like container registries, key vaults
- **Services**: Azure Container Registry, Azure Key Vault, Shared Storage Accounts
- **Management Group**: Platform MG

## Subscription Design Principles

### Naming Convention
```
{company}-{environment}-{purpose}-{region}

Examples:
- contoso-prod-management-eus
- contoso-prod-connectivity-eus
- contoso-prod-identity-eus
```

### Subscription Limits and Scaling
- Monitor Azure subscription limits
- Plan for multiple subscriptions per service type if needed
- Consider regional distribution of subscriptions

## Terraform Implementation

### Structure
```
20-platform-subscriptions/
├── README.md
├── main.tf                    # Main subscription creation
├── variables.tf               # Input variables
├── outputs.tf                 # Subscription outputs
├── versions.tf                # Provider versions
├── terraform.tfvars.example   # Example values
└── modules/
    └── subscription/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Key Resources
- Azure Subscription creation (using EA/MCA APIs)
- Management Group association
- Initial RBAC assignments
- Subscription-level policy assignments
- Resource provider registrations

## Prerequisites

### Permissions Required
- Account Administrator or Owner on Billing Account
- Management Group Contributor on target management groups
- Subscription Creator role (for EA agreements)

### Dependencies
- Completed tenant initialization (00-tenant-initialization)
- Management groups structure created (10-management-groups)
- Billing account configuration

## Deployment Process

### 1. Configuration
```bash
# Copy and customize the example tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vim terraform.tfvars
```

### 2. Terraform Deployment
```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Post-Deployment
- Verify subscription creation
- Confirm management group placement
- Validate RBAC assignments
- Test subscription access

## Cost Management

### Budgets and Alerts
- Set up subscription-level budgets
- Configure cost alerts
- Implement cost allocation tags

### Monitoring
- Track subscription spending
- Monitor resource usage
- Regular cost optimization reviews

## Next Steps

After platform subscriptions are created:
1. **30-platform-services** - Deploy shared platform services into these subscriptions
2. **40-spoke-workloads** - Create spoke subscriptions for application teams

## Troubleshooting

### Common Issues
- Insufficient billing permissions
- Management group assignment failures
- Subscription quota limits
- Provider registration failures

### Support Resources
- Azure subscription management documentation
- Enterprise Agreement portal
- Microsoft Customer Agreement portal

## Resources

- [Azure Subscription Management](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/)
- [Enterprise Agreement Subscriptions](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/ea-portal-get-started)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
