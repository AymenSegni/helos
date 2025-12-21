#!/bin/sh
#
# Bitcoin Core container entrypoint script.
# Handles configuration setup and graceful startup.
#
# Required environment variables:
#   BITCOIN_RPC_PASSWORD - RPC authentication password (required)
#
# Optional environment variables:
#   BITCOIN_RPC_USER     - RPC username (default: bitcoin)
#   BITCOIN_NETWORK      - Network: mainnet, testnet, signet, regtest (default: mainnet)
#   BITCOIN_DATA_DIR     - Data directory (default: /bitcoin/data)
#   BITCOIN_CONF_FILE    - Config file path (default: /etc/bitcoin/bitcoin.conf)
#   BITCOIN_EXTRA_ARGS   - Additional bitcoind arguments

set -e

# Colors for output (only if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    CYAN=''
    NC=''
fi

log_info() { echo "${CYAN}[INFO]${NC} $*"; }
log_success() { echo "${GREEN}[SUCCESS]${NC} $*"; }
log_error() { echo "${RED}[ERROR]${NC} $*" >&2; }

# ============================================================
# Validate required environment variables
# ============================================================

if [ -z "${BITCOIN_RPC_PASSWORD}" ]; then
    log_error "BITCOIN_RPC_PASSWORD environment variable is required!"
    log_error "Please set it via Kubernetes Secret or Docker environment."
    exit 1
fi

# ============================================================
# Set defaults
# ============================================================

BITCOIN_RPC_USER="${BITCOIN_RPC_USER:-bitcoin}"
BITCOIN_NETWORK="${BITCOIN_NETWORK:-mainnet}"
BITCOIN_DATA_DIR="${BITCOIN_DATA_DIR:-/bitcoin/data}"
BITCOIN_CONF_FILE="${BITCOIN_CONF_FILE:-/etc/bitcoin/bitcoin.conf}"

log_info "Starting Bitcoin Core..."
log_info "Network: ${BITCOIN_NETWORK}"
log_info "Data directory: ${BITCOIN_DATA_DIR}"

# ============================================================
# Ensure data directory exists and has correct permissions
# ============================================================

if [ ! -d "${BITCOIN_DATA_DIR}" ]; then
    log_info "Creating data directory: ${BITCOIN_DATA_DIR}"
    mkdir -p "${BITCOIN_DATA_DIR}"
fi

# ============================================================
# Build command line arguments
# ============================================================

ARGS=""

# Network selection
case "${BITCOIN_NETWORK}" in
    mainnet)
        # No special flag needed for mainnet
        ;;
    testnet)
        ARGS="${ARGS} -testnet"
        ;;
    signet)
        ARGS="${ARGS} -signet"
        ;;
    regtest)
        ARGS="${ARGS} -regtest"
        ;;
    *)
        log_error "Unknown network: ${BITCOIN_NETWORK}"
        log_error "Valid options: mainnet, testnet, signet, regtest"
        exit 1
        ;;
esac

# Core configuration
ARGS="${ARGS} -datadir=${BITCOIN_DATA_DIR}"
ARGS="${ARGS} -rpcuser=${BITCOIN_RPC_USER}"
ARGS="${ARGS} -rpcpassword=${BITCOIN_RPC_PASSWORD}"

# Enable RPC server
ARGS="${ARGS} -server=1"
ARGS="${ARGS} -rpcallowip=0.0.0.0/0"
ARGS="${ARGS} -rpcbind=0.0.0.0"

# Log to stdout for container logging
ARGS="${ARGS} -printtoconsole=1"

# Use config file if it exists
if [ -f "${BITCOIN_CONF_FILE}" ]; then
    log_info "Using config file: ${BITCOIN_CONF_FILE}"
    ARGS="${ARGS} -conf=${BITCOIN_CONF_FILE}"
fi

# Add any extra arguments
if [ -n "${BITCOIN_EXTRA_ARGS}" ]; then
    log_info "Extra arguments: ${BITCOIN_EXTRA_ARGS}"
    ARGS="${ARGS} ${BITCOIN_EXTRA_ARGS}"
fi

# Add any command line arguments passed to the script
if [ $# -gt 0 ]; then
    ARGS="${ARGS} $*"
fi

# ============================================================
# Setup graceful shutdown handler
# ============================================================

shutdown_handler() {
    log_info "Received shutdown signal, stopping Bitcoin Core gracefully..."
    if command -v bitcoin-cli >/dev/null 2>&1; then
        bitcoin-cli \
            -rpcuser="${BITCOIN_RPC_USER}" \
            -rpcpassword="${BITCOIN_RPC_PASSWORD}" \
            stop 2>/dev/null || true
    fi
    # Wait for bitcoind to stop (max 60 seconds)
    # shellcheck disable=SC2034
    for _ in $(seq 1 60); do
        if ! pgrep -x bitcoind >/dev/null; then
            log_success "Bitcoin Core stopped gracefully"
            exit 0
        fi
        sleep 1
    done
    log_error "Bitcoin Core did not stop gracefully, forcing..."
    exit 1
}

trap shutdown_handler TERM INT QUIT

# ============================================================
# Start Bitcoin Core
# ============================================================

log_success "Starting bitcoind with arguments:"
echo "  ${ARGS}"

# shellcheck disable=SC2086
exec bitcoind ${ARGS}
