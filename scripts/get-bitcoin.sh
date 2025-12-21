#!/usr/bin/env bash
#
# Download and verify Bitcoin Core binary with GPG signatures and checksums.
# This script is designed for use in Docker builds.
#
# Usage: get-bitcoin.sh <version> [<install-prefix>]
# Example: get-bitcoin.sh 29.0 /usr/local

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Supported versions (add new versions at the end)
SUPPORTED_VERSIONS=(
    "22.0"
    "23.0"
    "23.1"
    "24.0"
    "24.0.1"
    "25.0"
    "25.1"
    "26.0"
    "26.1"
    "27.0"
    "27.1"
    "28.0"
    "29.0"
)

# Bitcoin Core release signing keys (from https://github.com/bitcoin/bitcoin/tree/master/contrib/builder-keys)
# These are the fingerprints of the Guix attestation signers
SIGNING_KEYS=(
    "152812300785C96444D3334D17565732E08E5E41"  # Andrew Chow
    "0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D"  # Sjors Provoost
    "CFB16E21C950F67FA95E558F2EEB9F5CC09526C1"  # Michael Ford
    "6A8F9C266528E25AEB1D7731C2371D91CB716EA7"  # David Gould
    "ED9BDF7AD6A55E232E84524257FF9BDBCC301009"  # Pieter Wuille
)

VERSION="${1:-}"
INSTALL_PREFIX="${2:-/usr/local}"

if [[ -z "${VERSION}" ]]; then
    log_error "Usage: get-bitcoin.sh <version> [<install-prefix>]"
    echo ""
    echo "Available versions:"
    for v in "${SUPPORTED_VERSIONS[@]}"; do
        echo "  ${v}"
    done
    exit 1
fi

# Validate version is in supported list
version_supported=false
for v in "${SUPPORTED_VERSIONS[@]}"; do
    if [[ "${v}" == "${VERSION}" ]]; then
        version_supported=true
        break
    fi
done

if [[ "${version_supported}" != "true" ]]; then
    log_error "Version ${VERSION} is not in the supported versions list."
    log_error "Supported versions: ${SUPPORTED_VERSIONS[*]}"
    exit 1
fi

# Set up URLs and filenames
URL_BASE="https://bitcoincore.org/bin/bitcoin-core-${VERSION}"
ARCH="x86_64-linux-gnu"
FILENAME="bitcoin-${VERSION}-${ARCH}.tar.gz"

log_info "Downloading Bitcoin Core ${VERSION}..."
log_info "Install prefix: ${INSTALL_PREFIX}"

# Create temporary directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT
cd "${TMPDIR}"

# Download the binary, checksums, and signatures
log_info "Downloading files from ${URL_BASE}..."
curl -fsSLO "${URL_BASE}/SHA256SUMS"
curl -fsSLO "${URL_BASE}/SHA256SUMS.asc"
curl -fsSLO "${URL_BASE}/${FILENAME}"

# Import signing keys
log_info "Importing GPG signing keys..."
for key in "${SIGNING_KEYS[@]}"; do
    if gpg --keyserver hkps://keys.openpgp.org --recv-keys "${key}" 2>/dev/null || \
       gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "${key}" 2>/dev/null; then
        log_info "Imported key: ${key}"
    else
        log_warn "Could not import key: ${key} (continuing anyway)"
    fi
done

# Verify GPG signature
log_info "Verifying GPG signature..."
if gpg --verify SHA256SUMS.asc SHA256SUMS 2>&1 | grep -q "Good signature"; then
    log_success "GPG signature verified"
else
    # Check if at least one valid signature exists
    if gpg --verify SHA256SUMS.asc SHA256SUMS 2>&1 | grep -q "Good signature"; then
        log_success "GPG signature verified (at least one valid signature)"
    else
        log_error "GPG signature verification FAILED!"
        gpg --verify SHA256SUMS.asc SHA256SUMS 2>&1 || true
        exit 1
    fi
fi

# Verify SHA256 checksum
log_info "Verifying SHA256 checksum..."
EXPECTED_CHECKSUM=$(grep "${FILENAME}" SHA256SUMS | awk '{print $1}')
ACTUAL_CHECKSUM=$(sha256sum "${FILENAME}" | awk '{print $1}')

if [[ "${EXPECTED_CHECKSUM}" == "${ACTUAL_CHECKSUM}" ]]; then
    log_success "Checksum verified: ${ACTUAL_CHECKSUM}"
else
    log_error "Checksum verification FAILED!"
    log_error "Expected: ${EXPECTED_CHECKSUM}"
    log_error "Actual:   ${ACTUAL_CHECKSUM}"
    exit 1
fi

# Extract the archive
log_info "Extracting Bitcoin Core..."
tar -xzf "${FILENAME}"

# Find the extracted directory
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name 'bitcoin-*' | head -n 1)
if [[ -z "${EXTRACTED_DIR}" ]]; then
    log_error "Could not find extracted directory"
    exit 1
fi

# Remove bitcoin-qt (GUI) if present - we only need bitcoind and bitcoin-cli
rm -f "${EXTRACTED_DIR}/bin/bitcoin-qt" 2>/dev/null || true

# Copy binaries to install prefix
log_info "Installing to ${INSTALL_PREFIX}..."
mkdir -p "${INSTALL_PREFIX}/bin"
cp "${EXTRACTED_DIR}/bin/"* "${INSTALL_PREFIX}/bin/"

# Verify installation
log_info "Verifying installation..."
if "${INSTALL_PREFIX}/bin/bitcoind" --version; then
    log_success "Bitcoin Core ${VERSION} installed successfully!"
else
    log_error "Installation verification failed"
    exit 1
fi

echo ""
log_success "============================================"
log_success " Bitcoin Core ${VERSION} Installation Complete"
log_success " Binaries installed to: ${INSTALL_PREFIX}/bin"
log_success "============================================"
