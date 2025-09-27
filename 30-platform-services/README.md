WORK IN PROGRESS
# 30 - Platform Services

This folder contains the shared platform services that provide foundational capabilities across your Azure Landing Zone. These services are deployed into the platform subscriptions and consumed by spoke workloads.

## Core Platform Services

### Networking Services
The primary focus of platform services, providing connectivity foundation:

#### Hub Virtual Network
- **Purpose**: Central connectivity point for all spoke networks
- **Components**: Hub VNet, subnets for shared services, gateway subnet
- **Location**: Connectivity subscription

#### Network Security
- **Azure Firewall**: Centralized network security and traffic filtering
- **Network Security Groups**: Subnet and network interface level protection
- **DDoS Protection**: Network-level DDoS mitigation

#### Hybrid Connectivity
- **VPN Gateway**: Site-to-site and point-to-site VPN connectivity
- **ExpressRoute Gateway**: Private connectivity to on-premises
- **Virtual Network Peering**: Hub-spoke network topology

#### DNS Services
- **Azure DNS**: Public DNS hosting
- **Private DNS Zones**: Internal name resolution
- **DNS Forwarding**: Hybrid DNS resolution

### Monitoring and Management

#### Centralized Logging
- **Log Analytics Workspace**: Central log collection and analysis
- **Application Insights**: Application performance monitoring
- **Azure Monitor**: Infrastructure and application monitoring

#### Security and Compliance
- **Azure Security Center**: Security posture management
- **Azure Sentinel**: Security information and event management (SIEM)
- **Azure Policy**: Governance and compliance enforcement

### Identity Services

#### Directory Services
- **Azure AD Domain Services**: Managed domain services
- **Domain Controllers**: Windows Server domain controllers (if needed)
- **Azure AD Connect**: Hybrid identity synchronization

### Shared Services

#### Container Services
- **Azure Container Registry**: Shared container image repository
- **Azure Kubernetes Service**: Shared AKS clusters (if applicable)

#### Storage and Data
- **Shared Storage Accounts**: Common storage for platform services
- **Azure Key Vault**: Centralized secrets and certificate management
- **Azure Backup**: Centralized backup services

## Service Architecture

### Hub-Spoke Network Topology
```
        ┌─────────────────┐
        │   Hub VNet      │
        │  ┌───────────┐  │
        │  │  Firewall │  │
        │  └───────────┘  │
        │  ┌───────────┐  │
        │  │ VPN/ER GW │  │
        │  └───────────┘  │
        └─────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│Spoke 1│  │Spoke 2│  │Spoke 3│
│  VNet │  │  VNet │  │  VNet │
└───────┘  └───────┘  └───────┘
```

### Service Dependencies
- Networking services form the foundation
- Monitoring services require network connectivity
- Identity services integrate with networking and security
- Shared services consume networking and monitoring

## Implementation Structure

```
30-platform-services/
├── README.md
├── networking/
│   ├── hub-vnet/           # Hub virtual network
│   ├── firewall/           # Azure Firewall
│   ├── vpn-gateway/        # VPN Gateway
│   ├── expressroute/       # ExpressRoute Gateway
│   └── dns/                # DNS services
├── monitoring/
│   ├── log-analytics/      # Log Analytics workspace
│   ├── security-center/    # Security Center config
│   └── sentinel/           # Azure Sentinel
├── identity/
│   ├── adds/               # Azure AD Domain Services
│   └── domain-controllers/ # Windows Server DCs
└── shared-services/
    ├── container-registry/ # Azure Container Registry
    ├── key-vault/          # Azure Key Vault
    └── backup/             # Azure Backup
```

## Deployment Approach

### Phase 1: Core Networking
1. Deploy hub virtual network
2. Configure network security groups
3. Set up Azure Firewall
4. Implement DNS services

### Phase 2: Hybrid Connectivity
1. Deploy VPN Gateway (if required)
2. Configure ExpressRoute (if required)
3. Set up network peering
4. Test connectivity

### Phase 3: Monitoring Foundation
1. Deploy Log Analytics workspace
2. Configure Azure Monitor
3. Set up Security Center
4. Implement alerting

### Phase 4: Identity Services
1. Deploy Azure AD Domain Services (if required)
2. Configure domain controllers (if required)
3. Set up hybrid identity

### Phase 5: Shared Services
1. Deploy container registry
2. Set up Key Vault
3. Configure backup services
4. Implement additional shared services

## Configuration Management

### Infrastructure as Code
- Use Terraform for infrastructure deployment
- Implement GitOps workflows
- Version control all configurations
- Automated testing and validation

### Service Configuration
- Standardized service configurations
- Environment-specific parameters
- Security baseline enforcement
- Compliance monitoring

## Prerequisites

### Completed Prerequisites
- Tenant initialization (00-tenant-initialization)
- Management groups structure (10-management-groups)
- Platform subscriptions (20-platform-subscriptions)

### Permissions Required
- Contributor access to platform subscriptions
- Network Contributor for networking resources
- Security Administrator for security services

## Next Steps

After platform services deployment:
1. **40-spoke-workloads** - Enable application teams to consume platform services
2. Spoke subscription creation and peering
3. Application team onboarding

## Troubleshooting

### Common Issues
- Network connectivity problems
- Service configuration conflicts
- Permissions and RBAC issues
- Resource quota limitations

### Monitoring and Alerting
- Service health monitoring
- Performance metrics
- Security event monitoring
- Cost optimization alerts

## Resources

- [Azure Networking Documentation](https://docs.microsoft.com/en-us/azure/networking/)
- [Hub-Spoke Network Topology](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke)
- [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/)
- [Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/)
