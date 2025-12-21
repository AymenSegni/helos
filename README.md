# Helos - Bitcoin Core 29.0 Production EKS Deployment

[![Dev Deployment](https://github.com/AymenSegni/helos/actions/workflows/dev-deployment.yml/badge.svg)](https://github.com/YOUR_ORG/helos/actions/workflows/dev-deployment.yml)
[![Prod Deployment](https://github.com/AymenSegni/helos/actions/workflows/prod-deployment.yml/badge.svg)](https://github.com/YOUR_ORG/helos/actions/workflows/prod-deployment.yml)
[![Terraform CI](https://github.com/AymenSegni/helos/actions/workflows/terraform-ci-sec.yaml/badge.svg)](https://github.com/YOUR_ORG/helos/actions/workflows/terraform-ci-sec.yaml)

Production-grade Bitcoin Core 29.0 node on AWS EKS with multi-environment support.

## Architecture

```bash
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                      │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC (Multi-AZ)                                │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    EKS Cluster                                  │  │  │
│  │  │  ┌─────────────────────────────────────────────────────────┐    │  │  │
│  │  │  │              bitcoin-prod namespace                     │    │  │  │
│  │  │  │  ┌─────────────────┐    ┌─────────────────────────────┐ │    │  │  │
│  │  │  │  │   StatefulSet   │    │     Services                │ │    │  │  │
│  │  │  │  │   ┌─────────┐   │    │  • ClusterIP (RPC:8332)     │ │    │  │  │
│  │  │  │  │   │bitcoind │   │    │  • Headless (P2P:8333)      │ │    │  │  │
│  │  │  │  │   │ :8332   │◄──┼────┤                             │ │    │  │  │
│  │  │  │  │   │ :8333   │   │    └─────────────────────────────┘ │    │  │  │
│  │  │  │  │   └────┬────┘   │                                    │    │  │  │
│  │  │  │  │        │        │    ┌─────────────────────────────┐ │    │  │  │
│  │  │  │  │   ┌────▼────┐   │    │     Network Policy          │ │    │  │  │
│  │  │  │  │   │   PVC   │   │    │  • Deny-all default         │ │    │  │  │
│  │  │  │  │   │ (gp3)   │   │    │  • Allow P2P from anywhere  │ │    │  │  │
│  │  │  │  │   │ 600Gi   │   │    │  • Allow RPC from namespace │ │    │  │  │
│  │  │  │  │   └─────────┘   │    └─────────────────────────────┘ │    │  │  │
│  │  │  │  └─────────────────┘                                    │    │  │  │
│  │  │  └─────────────────────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4-Layer Terraform Architecture

| Layer | Directory | Purpose |
|-------|-----------|---------|
| 1 | `bootstraping/` | OIDC, S3 Backend (run once locally) |
| 2 | `infra/` | VPC, EKS, IAM, ECR |
| 3 | `cluster-addons/` | Namespace, SA, StorageClass, NetworkPolicy |
| 4 | `btcd-core/` | Bitcoin Core StatefulSet (Helm) |

> **Note:** This project uses a **layered Terraform/Helm architecture** designed for production environments, rather than a simple flat structure. This demonstrates real-world patterns:
>
> - **State isolation** between infrastructure layers
> - **Environment separation** (dev/prod with tfvars)
> - **Modular infrastructure-as-code** with reusable modules
> - **GitOps workflow** with PR-based deployments
>
> While more complex than a minimal demo, this architecture reflects how production SRE teams actually manage infrastructure at scale.

## Project Structure

```
helos/
├── Dockerfile               # Multi-stage, distroless container
├── bootstraping/            # Layer 1: OIDC + S3 state backend
│   ├── deploy/              # Root module + tfvars
│   └── modules/             # gha-oidc, s3-tfstate
├── infra/                   # Layer 2: Core AWS infrastructure
│   ├── deploy/              # Root module + tfvars
│   └── modules/             # vpc, eks, iam, ecr
├── cluster-addons/          # Layer 3: Kubernetes platform
│   ├── deploy/
│   ├── modules/             # helm-release
│   └── charts/              # cluster-addons Helm chart
├── btcd-core/               # Layer 4: Bitcoin Core
│   ├── deploy/
│   ├── modules/             # helm-release
│   └── charts/              # bitcoind Helm chart
├── scripts/                 # Automation & Docker scripts
│   ├── bootstrap.sh
│   ├── get-bitcoin.sh       # GPG-verified download
│   ├── smoke-test.sh
│   └── health-check.sh
└── .github/
    ├── actions/             # Reusable composite actions
    └── workflows/           # dev/prod deployment
```

## Quick Start

### Prerequisites

```bash
# Verify required tools
make check-tools
```

| Tool | Version |
|------|---------|
| Docker | 24.0+ |
| Terraform | 1.9+ |
| AWS CLI | 2.x |
| kubectl | 1.28+ |
| Helm | 3.x |

### 1. Bootstrap (Run Once Locally)

```bash
# Creates OIDC provider and S3 state backend
./scripts/bootstrap.sh YOUR_ORG helos

# Add output role ARN to GitHub repository variables:
# AWS_OIDC_ROLE_ARN_DEV  = arn:aws:iam::xxx:role/helos-dev-github-actions
# AWS_OIDC_ROLE_ARN_PROD = arn:aws:iam::xxx:role/helos-prod-github-actions
```

### 2. CI/CD Workflow

| Event | Workflow | Action |
|-------|----------|--------|
| PR opened → `main` | `pr-plan.yml` | Terraform plan (all layers) |
| PR merged → `main` | `dev-deployment.yml` | Deploy to **dev** |
| Manual trigger | `prod-deployment.yml` | Deploy to **prod** (requires confirmation) |
| Release published | `prod-deployment.yml` | Deploy to **prod** |

```bash
# Open a PR to main → runs terraform plan
git checkout -b feature/my-change
git push origin feature/my-change
# Create PR → plan runs automatically

# Merge PR → deploys to dev
# Release → deploys to prod
```

### 3. Manual Deployment

```bash
# Deploy dev environment
make tf-infra ENV=dev
make tf-addons ENV=dev
make tf-btcd ENV=dev

# Verify deployment
make verify-deployment
```

## Environments

| | Dev | Prod |
|---|-----|------|
| **Trigger** | PR merge to `main` | Manual / Release |
| **Network** | testnet | mainnet |
| **Storage** | 50Gi | 600Gi |
| **Nodes** | t3.medium (1-2) | m5.large (2-5) |
| **NAT** | Single | Multi-AZ HA |
| **Namespace** | `bitcoin-dev` | `bitcoin-prod` |

## Security

| Feature | Implementation |
|---------|----------------|
| Non-root Container | UID 65532 (distroless) |
| Read-only Root FS | Immutable container |
| GPG Verification | Binary signatures verified |
| Network Policy | Deny-all + explicit allows |
| IRSA | Pod Identity for AWS access |
| Seccomp | RuntimeDefault profile |

## Makefile Targets

```bash
make help              # Show all targets

# Terraform
make tf-init-all       # Init all layers
make tf-validate-all   # Validate all layers
make tf-fmt            # Format all TF files

# Helm
make helm-lint         # Lint all charts

# Docker
make docker-build      # Build image
make docker-scan       # Scan with Trivy

# Verification
make smoke-test        # Run smoke tests
make health-check      # Check Bitcoin Core
make verify-deployment # Both
```

## Verification

```bash
# Smoke test verifies:
# ✓ ECR repository exists
# ✓ EKS cluster is ACTIVE
# ✓ Namespace, SA, StorageClass
# ✓ StatefulSet, Pods, Services

# Health check verifies:
# ✓ Pod is running
# ✓ Bitcoin Core RPC responding
# ✓ Blockchain sync progress
# ✓ Peer connections
```

## References

- [Bitcoin Core](https://bitcoincore.org/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [cloudposse/terraform-aws-helm-release](https://github.com/cloudposse/terraform-aws-helm-release)

