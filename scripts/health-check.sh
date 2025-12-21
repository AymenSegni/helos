#!/usr/bin/env bash
#
# Health check for Bitcoin Core node
# Verifies that the Bitcoin Core node is running and syncing correctly.
#
# Usage: ./scripts/health-check.sh
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
POD_NAME="${POD_NAME:-bitcoind-0}"
TIMEOUT="${TIMEOUT:-60}"

echo ""
log_info "============================================"
log_info " Bitcoin Core Health Check"
log_info "============================================"
log_info "Namespace: ${NAMESPACE}"
log_info "Pod:       ${POD_NAME}"
echo ""

# ============================================================
# Check pod is running
# ============================================================
log_info "Checking pod status..."

POD_STATUS=$(kubectl get pod "${POD_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")

if [[ "${POD_STATUS}" != "Running" ]]; then
    log_error "Pod is not running. Status: ${POD_STATUS}"
    exit 1
fi
log_success "Pod is running"

# ============================================================
# Check container is ready
# ============================================================
log_info "Checking container readiness..."

CONTAINER_READY=$(kubectl get pod "${POD_NAME}" -n "${NAMESPACE}" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")

if [[ "${CONTAINER_READY}" != "true" ]]; then
    log_warn "Container not yet ready (this is expected during initial sync)"
else
    log_success "Container is ready"
fi

# ============================================================
# Get blockchain info via RPC
# ============================================================
log_info "Querying Bitcoin Core RPC..."

# Get RPC credentials from secret
RPC_USER=$(kubectl get secret bitcoind-rpc -n "${NAMESPACE}" -o jsonpath='{.data.rpcuser}' 2>/dev/null | base64 -d || echo "bitcoin")
RPC_PASS=$(kubectl get secret bitcoind-rpc -n "${NAMESPACE}" -o jsonpath='{.data.rpcpassword}' 2>/dev/null | base64 -d || echo "")

if [[ -z "${RPC_PASS}" ]]; then
    log_error "Could not retrieve RPC password from secret"
    exit 1
fi

# Execute bitcoin-cli in pod
BLOCKCHAIN_INFO=$(kubectl exec "${POD_NAME}" -n "${NAMESPACE}" -- \
    bitcoin-cli -rpcuser="${RPC_USER}" -rpcpassword="${RPC_PASS}" -rpcconnect=127.0.0.1 \
    getblockchaininfo 2>/dev/null || echo "{}")

if [[ "${BLOCKCHAIN_INFO}" == "{}" ]] || [[ -z "${BLOCKCHAIN_INFO}" ]]; then
    log_warn "Could not get blockchain info (node may still be starting)"
    echo ""
    log_info "Checking if bitcoind process is running..."
    kubectl exec "${POD_NAME}" -n "${NAMESPACE}" -- pgrep -x bitcoind > /dev/null 2>&1 && \
        log_success "bitcoind process is running" || \
        log_error "bitcoind process not found"
    exit 0
fi

# Parse blockchain info
CHAIN=$(echo "${BLOCKCHAIN_INFO}" | jq -r '.chain // "unknown"')
BLOCKS=$(echo "${BLOCKCHAIN_INFO}" | jq -r '.blocks // 0')
HEADERS=$(echo "${BLOCKCHAIN_INFO}" | jq -r '.headers // 0')
VERIFICATION_PROGRESS=$(echo "${BLOCKCHAIN_INFO}" | jq -r '.verificationprogress // 0')
INITIAL_BLOCK_DOWNLOAD=$(echo "${BLOCKCHAIN_INFO}" | jq -r '.initialblockdownload // false')

log_success "Bitcoin Core RPC responding"
echo ""
log_info "--- Blockchain Status ---"
echo "  Chain:                ${CHAIN}"
echo "  Blocks:               ${BLOCKS}"
echo "  Headers:              ${HEADERS}"
echo "  Sync Progress:        $(echo "${VERIFICATION_PROGRESS} * 100" | bc -l 2>/dev/null | cut -c1-6 || echo "${VERIFICATION_PROGRESS}")%"
echo "  Initial Block Download: ${INITIAL_BLOCK_DOWNLOAD}"

# ============================================================
# Get network info
# ============================================================
log_info ""
log_info "Querying network info..."

NETWORK_INFO=$(kubectl exec "${POD_NAME}" -n "${NAMESPACE}" -- \
    bitcoin-cli -rpcuser="${RPC_USER}" -rpcpassword="${RPC_PASS}" -rpcconnect=127.0.0.1 \
    getnetworkinfo 2>/dev/null || echo "{}")

if [[ "${NETWORK_INFO}" != "{}" ]]; then
    VERSION=$(echo "${NETWORK_INFO}" | jq -r '.version // "unknown"')
    SUBVERSION=$(echo "${NETWORK_INFO}" | jq -r '.subversion // "unknown"')
    CONNECTIONS=$(echo "${NETWORK_INFO}" | jq -r '.connections // 0')
    CONNECTIONS_IN=$(echo "${NETWORK_INFO}" | jq -r '.connections_in // 0')
    CONNECTIONS_OUT=$(echo "${NETWORK_INFO}" | jq -r '.connections_out // 0')

    log_info "--- Network Status ---"
    echo "  Version:          ${VERSION}"
    echo "  Subversion:       ${SUBVERSION}"
    echo "  Connections:      ${CONNECTIONS} (in: ${CONNECTIONS_IN}, out: ${CONNECTIONS_OUT})"
fi

# ============================================================
# Summary
# ============================================================
echo ""
log_info "============================================"
if [[ "${INITIAL_BLOCK_DOWNLOAD}" == "true" ]]; then
    log_warn "Node is still syncing (Initial Block Download in progress)"
    log_info "This is expected for a new node. Full sync takes several days."
else
    log_success "Bitcoin Core node is healthy and synced!"
fi
echo ""

exit 0
