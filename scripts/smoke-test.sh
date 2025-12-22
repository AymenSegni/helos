#!/usr/bin/env bash
#
# Smoke test for Helos deployment
# Verifies that all infrastructure components are deployed correctly.
#
# Usage: ./scripts/smoke-test.sh
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[FAIL]${NC} $*" >&2; }

NAMESPACE="${NAMESPACE:-bitcoin-prod}"
ECR_REPO="${ECR_REPO:-bitcoind}"
CLUSTER_NAME="${CLUSTER_NAME:-helos}"
AWS_REGION="${AWS_REGION:-eu-west-1}"

FAILURES=0

check() {
    local name="$1"
    local command="$2"

    log_info "Checking: ${name}..."
    if eval "${command}" > /dev/null 2>&1; then
        log_success "${name}"
        return 0
    else
        log_error "${name}"
        FAILURES=$((FAILURES + 1))
        return 1
    fi
}

echo ""
log_info "============================================"
log_info " Helos Smoke Test"
log_info "============================================"
log_info "Cluster:   ${CLUSTER_NAME}"
log_info "Namespace: ${NAMESPACE}"
log_info "Region:    ${AWS_REGION}"
echo ""

# ============================================================
# AWS Infrastructure Checks
# ============================================================
log_info "--- AWS Infrastructure ---"

check "ECR Repository exists" \
    "aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION}"

check "ECR has images" \
    "aws ecr list-images --repository-name ${ECR_REPO} --region ${AWS_REGION} --query 'imageIds[0]' --output text | grep -v '^None$'"

check "EKS Cluster exists" \
    "aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION}"

check "EKS Cluster is ACTIVE" \
    "aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query 'cluster.status' --output text | grep -q ACTIVE"

# ============================================================
# Kubernetes Checks
# ============================================================
log_info ""
log_info "--- Kubernetes Resources ---"

# Update kubeconfig
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_REGION}" > /dev/null 2>&1 || true

check "Namespace exists" \
    "kubectl get namespace ${NAMESPACE}"

check "ServiceAccount exists" \
    "kubectl get serviceaccount bitcoind -n ${NAMESPACE}"

check "StorageClass gp3 exists" \
    "kubectl get storageclass gp3"

check "StatefulSet exists" \
    "kubectl get statefulset bitcoind -n ${NAMESPACE}"

check "StatefulSet has ready replicas" \
    "kubectl get statefulset bitcoind -n ${NAMESPACE} -o jsonpath='{.status.readyReplicas}' | grep -q '[1-9]'"

check "Pod is Running" \
    "kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=bitcoind -o jsonpath='{.items[0].status.phase}' | grep -q Running"

check "PVC is Bound" \
    "kubectl get pvc -n ${NAMESPACE} -l app.kubernetes.io/name=bitcoind -o jsonpath='{.items[0].status.phase}' | grep -q Bound"

check "RPC Service exists" \
    "kubectl get service bitcoind-rpc -n ${NAMESPACE}"

check "Headless Service exists" \
    "kubectl get service bitcoind-headless -n ${NAMESPACE}"

# ============================================================
# Summary
# ============================================================
echo ""
log_info "============================================"
if [[ ${FAILURES} -eq 0 ]]; then
    log_success "All smoke tests passed!"
    exit 0
else
    log_error "${FAILURES} test(s) failed"
    exit 1
fi
