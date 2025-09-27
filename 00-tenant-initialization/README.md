# 00 - Tenant Initialization

This folder contains guidance and resources for initially setting up your Azure tenant when it is a fresh setup.

## Overview

When starting with a new Azure tenant, there are several foundational steps that need to be completed before implementing the Azure Landing Zone. This section provides step-by-step guidance for tenant initialization.

## Prerequisites

- New Azure tenant with Global Administrator access
- Azure CLI or PowerShell installed
- Appropriate licensing (Azure AD Premium P1/P2 if required)

## Initial Setup Steps

### 1. Tenant Configuration
- Configure tenant-level settings
- Set up custom domain names
- Configure tenant branding
- Enable security defaults or Conditional Access

### 2. Identity and Access Management
- Create break-glass accounts
- Configure Multi-Factor Authentication (MFA)
- Set up Privileged Identity Management (PIM)
- Define administrative roles and assignments

### 3. Security Baseline
- Enable Azure Security Center
- Configure security policies
- Set up activity logging
- Implement compliance frameworks

### 4. Billing and Cost Management
- Set up billing accounts and profiles
- Configure cost management and budgets
- Implement cost allocation tags strategy
- Set up spending alerts

### 5. Governance Foundation
- Create initial Azure Policy definitions
- Set up management groups structure preparation
- Configure subscription governance model
- Implement naming conventions

## Next Steps

Once tenant initialization is complete, proceed to:
1. **10-management-groups** - Implement the management group hierarchy
2. **20-platform-subscriptions** - Create platform subscriptions
3. **30-platform-services** - Deploy shared platform services
4. **40-spoke-workloads** - Enable application teams

## Resources

- [Azure Landing Zone Documentation](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Tenant Setup Best Practices](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/)
- [Azure Security Baseline](https://docs.microsoft.com/en-us/security/benchmark/azure/)
