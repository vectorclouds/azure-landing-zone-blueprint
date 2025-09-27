# 10 - Management Groups

This folder contains the structure and configuration for Azure Management Groups that form the hierarchical foundation of your Azure Landing Zone.

The sole purpose (ignoring that it helps to keep things tidy) of management groups is that Azure policies apply either at an management group, a subscription, or a resource group level.

Not utilizing management groups well will lead to chaotic policy assignments across subscription to put it mildly.

## Management Group Hierarchy

I recommended management group structure following the below hierarchy:

```
Tenant Root Group
└── Main Company
    ├── Landing Zones
    │   ├── Corporate
    │   ├── Online
    │   ├── Platform
    │   └── Sandbox
    └── Decommissioned
```

## Management Group Purpose

### Root Level
- **Tenant Root Group**: Default root management group for the tenant
- **Main Company MG**: Top-level management group for your organization (might be the same as the tenant root group)

### Landing Zone Management Groups
- **Landing Zones**: Contains all flavours of landing zones incl. platform
  - **Corporate**: Corporate applications with on-premises connectivity
  - **Online**: (Internet-facing) applications without the need to access company data
  - **Platform**: All 

### Platform Management Groups
- **Platform MG**: Contains all platform-related subscriptions
  - **Management**: Centrally provided management + things like reservations management might go here
  - **Networking**: Network connectivity subscriptions (Hub VNets, ExpressRoute, VPN, Firewalls, Proxy(?))
  - **Identity**: Identity services subscriptions (Domain Controllers, AAD)

### Environment-Specific Structure
Under each Landing Zone MG, create environment-specific management groups:
- **Dev**: Development environments
- **NonProd**: Test, staging, and pre-production environments  
- **Prod**: Production environments

### Special Purpose
- **Sandbox**: Isolated environments for experimentation
- **Decommissioned**: Subscriptions pending deletion

## Governance and Policies

Each management group level applies specific Azure Policies:

- **Tenant Root**: Baseline security and compliance policies
- **Main Company**: Organization-wide governance policies
- **Landing Zones**: Type-specific policies
- **Platform**: Platform-specific policies (IAM, networking)
- **Environment-specific**: Environment-appropriate policies (prod vs dev)

## Implementation

### Prerequisites
- Completed tenant initialization (00-tenant-initialization)
- Management Group Contributor role
- Azure CLI or PowerShell with Az modules

### Deployment Steps
1. Create management group hierarchy
2. Apply Azure Policy assignments
3. Configure RBAC at management group level
4. Set up billing and cost allocation

## Next Steps

After establishing management groups:
1. **20-platform-subscriptions** - Create and organize platform subscriptions
2. **30-platform-services** - Deploy shared platform services
3. **40-spoke-workloads** - Enable application team deployments

## Resources

- [Management Groups Documentation](https://docs.microsoft.com/en-us/azure/governance/management-groups/)
- [Azure Landing Zone Management Groups](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups)
- [Azure Policy for Management Groups](https://docs.microsoft.com/en-us/azure/governance/policy/overview)
