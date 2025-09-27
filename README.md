# Azure Landing Zone Blueprint

A practical, governance-first blueprint that mirrors how (some) enterprises actually set up Azure:
1) **Tenant/bootstrap** (some portal/CLI/PIM steps)
2) **Terraform** for management groups, policy-as-code, subscriptions, platform, and application workloads

> Personal project. Built from scratch with generic patterns and synthetic values. No employer IP.


## Why this repo?
- **Realistic flow**: documents unavoidable tenant steps, then automates everything else.
- **Guardrails first**: management groups + policy assignments before platform/services.
- **Extendable**: start small; grow modules and examples incrementally.


## High-level flow

