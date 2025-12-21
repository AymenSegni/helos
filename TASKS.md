# Task Solutions

This document describes how each task in the exercise was implemented.

---

## Task 1: Containerization - Bitcoin Core 29.0

**Goal:** Container image that runs bitcoind as non-root with logs to stdout.

### Implementation

**File:** [`Dockerfile`](Dockerfile)

| Requirement | Implementation |
|-------------|----------------|
| Pin Bitcoin Core 29.0 | `ARG VERSION=29.0` with official download URL |
| Checksum/signature verification | GPG verification in [`scripts/get-bitcoin.sh`](scripts/get-bitcoin.sh) |
| Non-root runtime | Distroless `nonroot` base image (UID 65532) |
| Minimal base image | `gcr.io/distroless/base-debian12:nonroot` |
| Data directory | `/var/lib/bitcoin` (configurable via env) |
| Logs to stdout | `-printtoconsole=1` default flag |
| Health check | Kubernetes probes with `bitcoin-cli getblockchaininfo` |
| Security scan | Trivy scan in CI with threshold: 0 Critical, 0 High |

### Verification

```bash
# Build shows GPG verification
docker build -t bitcoind:29.0 .

# Runs and streams logs
docker run bitcoind:29.0

# Verify non-root
docker run --entrypoint="" bitcoind:29.0 whoami
# nonroot
```

### Design Decisions

- **Distroless over Alpine:** Smaller attack surface, no shell for attackers to exploit
- **Multi-stage build:** Builder stage handles GPG verification, runtime has only binaries
- **No HEALTHCHECK instruction:** Distroless doesn't support it; using Kubernetes probes instead

---

## Task 2: Kubernetes Orchestration

**Goal:** Run container on k8s with security and availability best practices.

### Implementation

**Files:**

- [`btcd-core/charts/bitcoind/`](btcd-core/charts/bitcoind/) - Helm chart
- [`btcd-core/charts/bitcoind/templates/statefulset.yaml`](btcd-core/charts/bitcoind/templates/statefulset.yaml)

| Requirement | Implementation |
|-------------|----------------|
| StatefulSet | Used for persistent identity and ordered deployment |
| PersistentVolumeClaim | 600Gi gp3 for mainnet, 50Gi for testnet |
| runAsNonRoot | `securityContext.runAsNonRoot: true` |
| readOnlyRootFilesystem | `securityContext.readOnlyRootFilesystem: true` |
| Drop capabilities | `capabilities.drop: ["ALL"]` |
| seccompProfile | `seccompProfile.type: RuntimeDefault` |
| Readiness probe | `bitcoin-cli -rpcwait getblockchaininfo` |
| Liveness probe | Same RPC check with longer thresholds |
| Service (ClusterIP) | Port 8332 for RPC |
| NetworkPolicy | Deny-all default + allow P2P (8333) + allow RPC from namespace |
| PodDisruptionBudget | `minAvailable: 1` |
| Resource requests/limits | CPU: 500m-2, Memory: 2Gi-8Gi |

### Verification

```bash
kubectl apply -f btcd-core/charts/bitcoind/templates/
kubectl get pods -n bitcoin-prod  # READY 1/1
kubectl delete pod bitcoind-0     # Auto-recovers with data intact
```

### Design Decisions

- **StatefulSet over Deployment:** Bitcoin Core is stateful; needs stable identity and persistent storage
- **Helm over raw manifests:** Enables environment-specific values (dev/prod)
- **emptyDir for tmp:** Allows runtime writes while keeping rootfs read-only

---

## Task 3: CI/CD Pipeline

**Goal:** Build, scan, deploy, verify with automated stages.

### Implementation

**Files:**

- [`.github/workflows/dev-deployment.yml`](.github/workflows/dev-deployment.yml)
- [`.github/workflows/prod-deployment.yml`](.github/workflows/prod-deployment.yml)
- [`.github/workflows/pr-plan.yml`](.github/workflows/pr-plan.yml)
- [`.github/workflows/terraform-ci-sec.yaml`](.github/workflows/terraform-ci-sec.yaml)

### Pipeline Stages

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    Build     │───▶│     Scan     │───▶│    Deploy    │───▶│    Verify    │
│  - Docker    │    │  - Trivy     │    │  - Terraform │    │  - Rollout   │
│  - Cache     │    │  - Checkov   │    │  - Helm      │    │  - RPC check │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
```

| Requirement | Implementation |
|-------------|----------------|
| Build with cache | `docker/build-push-action` with GHA cache |
| Pinned base image | Explicit tags in Dockerfile |
| Push to registry | AWS ECR |
| Scan with threshold | Trivy: CRITICAL=0, HIGH=0; Checkov for Terraform |
| Deploy to cluster | Terraform apply + Helm release |
| Verify health | `kubectl rollout status` + RPC healthcheck |

### Workflow Triggers

| Event | Workflow | Action |
|-------|----------|--------|
| PR opened | `pr-plan.yml` | Validate, plan, lint (no credentials for scan) |
| PR merged to main | `dev-deployment.yml` | Full deploy to dev |
| Manual/Release | `prod-deployment.yml` | Full deploy to prod (confirmation required) |

### Design Decisions

- **Layered Terraform:** State isolation between infra/addons/app
- **OIDC authentication:** No long-lived AWS credentials in secrets
- **Separate validation workflow:** PR checks don't need AWS access

---

## Task 4: Log Analysis (Shell)

**Goal:** Print IP address frequency from web logs using shell.

### Implementation

**File:** [`scripts/ip-count.sh`](scripts/ip-count.sh)

```bash
#!/bin/bash
# Extract IP (field 2), count, sort descending
awk '
    /^[[:space:]]*$/ { next }
    NF < 2 { next }
    {
        ip = $2
        if (ip ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
            count[ip]++
        }
    }
    END { for (ip in count) print count[ip], ip }
' "$input" | sort -rn
```

### Usage

```bash
./scripts/ip-count.sh scripts/sample.log
# Output:
# 6 192.168.22.11
# 4 10.32.89.34
# 1 192.168.21.34
# 1 172.32.9.12
# 1 121.89.25.43

# Or via stdin
cat access.log | ./scripts/ip-count.sh
```

### Design Decisions

- **AWK for parsing:** Efficient for large log files, single-pass processing
- **IP validation regex:** Basic format check, skips malformed lines
- **Graceful handling:** Blank lines and malformed entries are silently skipped

---

## Task 5: Log Analysis (Python)

**Goal:** Solve Task 4 in a general-purpose language with unit tests.

### Implementation

**Files:**

- [`scripts/ip_count.py`](scripts/ip_count.py) - Main implementation
- [`scripts/test_ip_count.py`](scripts/test_ip_count.py) - Unit tests

### Key Functions

```python
def parse_ip_from_line(line: str) -> Optional[str]:
    """Extract and validate IP from log line."""

def count_ips(input_stream: TextIO) -> Counter:
    """Count IP occurrences from stream."""

def format_output(ip_counts: Counter) -> str:
    """Format as sorted output string."""
```

### Usage

```bash
# From file
python3 scripts/ip_count.py --file scripts/sample.log

# From stdin
cat access.log | python3 scripts/ip_count.py

# Run tests (10 tests)
cd scripts && python3 -m unittest test_ip_count -v
```

### Test Coverage

- `TestParseIpFromLine`: Valid lines, blank lines, malformed, invalid IPs
- `TestCountIps`: Basic counting, skip blanks, skip malformed, empty input
- `TestFormatOutput`: Descending sort, empty counter

### Design Decisions

- **No external dependencies:** Standard library only (argparse, re, collections)
- **Python 3.9 compatible:** Uses `Optional[str]` instead of `str | None`
- **Type hints:** Full typing for documentation and IDE support

---

## Task 6: IAM Terraform Module

**Goal:** Create 4 IAM resources with consistent naming.

### Implementation

**Files:**

- [`terraform/iam-module/main.tf`](terraform/iam-module/main.tf)
- [`terraform/iam-module/variables.tf`](terraform/iam-module/variables.tf)
- [`terraform/iam-module/outputs.tf`](terraform/iam-module/outputs.tf)
- [`terraform/iam-module/examples/main.tf`](terraform/iam-module/examples/main.tf)

### Resources Created

| Resource | Purpose |
|----------|---------|
| `aws_iam_role` | Assumable by identities in same account |
| `aws_iam_policy` | Grants `sts:AssumeRole` on the role |
| `aws_iam_group` | Policy attached |
| `aws_iam_user` | Added to group |

### Usage

```hcl
module "iam_resources" {
  source = "./terraform/iam-module"

  name = "bitcoin-operator"
  path = "/"

  tags = {
    Environment = "dev"
    Project     = "helos"
  }
}
```

### Verification

```bash
cd terraform/iam-module/examples
terraform init
terraform plan   # Shows 5 resources to create
terraform apply  # Creates all resources
terraform destroy # Clean removal
```

### Outputs

- `role_arn`, `role_name`
- `policy_arn`, `policy_name`
- `group_arn`, `group_name`
- `user_arn`, `user_name`

### Design Decisions

- **Same-account assumption:** Trust policy allows principals from same AWS account
- **Group-based access:** User gets permissions via group membership (best practice)
- **Minimal privileges:** Policy only allows assuming the specific role

---

## Architecture Note

This project uses a **production-grade layered architecture** rather than a simple flat structure:

```
bootstraping/  → OIDC + S3 backend (Layer 1)
infra/         → VPC, EKS, ECR (Layer 2)
cluster-addons/→ K8s platform config (Layer 3)
btcd-core/     → Bitcoin Core app (Layer 4)
```

**Why this approach:**

- **State isolation:** Each layer has its own Terraform state
- **Failure isolation:** App changes don't risk infra state
- **Team scaling:** Different teams can own different layers
- **Environment separation:** dev.tfvars vs prod.tfvars per layer

This demonstrates real-world SRE practices beyond the scope of a simple exercise.

---

## AI Tool Usage Disclosure

Tool: Claude (Anthropic). AI was used for:

- Debugging CI/CD workflow issues:

    - AI help in fixing Helm provider version constraint (`>= 2.12` → `>= 2.12, < 3.0`) to maintain `kubernetes {}` block syntax
    - Fixed shellcheck warning for unused loop variable in `entrypoint.sh`

- Assisted in Writing the documentation
