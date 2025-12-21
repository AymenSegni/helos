# ============================================================
# Stage 1: Builder
# Download, verify, and extract Bitcoin Core binaries
# ============================================================
FROM ubuntu:22.04 AS builder

# Build arguments
ARG VERSION=29.0
ARG TARGETARCH=amd64

# Install required packages for download and verification
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Copy and run the download script
COPY scripts/get-bitcoin.sh /usr/local/bin/get-bitcoin.sh
RUN chmod +x /usr/local/bin/get-bitcoin.sh

# Download and verify Bitcoin Core
# This step will fail if GPG or checksum verification fails
RUN /usr/local/bin/get-bitcoin.sh "${VERSION}" /bitcoin

# Verify the binaries were installed
RUN /bitcoin/bin/bitcoind --version

# ============================================================
# Stage 2: Runtime
# Minimal production image with only the required binaries
# ============================================================
FROM gcr.io/distroless/base-debian12:nonroot

# Labels for OCI compliance
LABEL org.opencontainers.image.title="Bitcoin Core"
LABEL org.opencontainers.image.description="Production-grade Bitcoin Core node"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.vendor="Bitcoin Core"
LABEL org.opencontainers.image.source="https://github.com/bitcoin/bitcoin"
LABEL org.opencontainers.image.licenses="MIT"

# Copy binaries from builder stage
# Only copy what's needed: bitcoind, bitcoin-cli, bitcoin-tx, bitcoin-util
COPY --from=builder /bitcoin/bin/bitcoind /usr/local/bin/bitcoind
COPY --from=builder /bitcoin/bin/bitcoin-cli /usr/local/bin/bitcoin-cli
COPY --from=builder /bitcoin/bin/bitcoin-tx /usr/local/bin/bitcoin-tx
COPY --from=builder /bitcoin/bin/bitcoin-util /usr/local/bin/bitcoin-util

# Copy entrypoint script
# Note: For distroless, we use a statically compiled wrapper or 
# embed configuration directly. Since distroless has no shell,
# we'll configure via command-line arguments.

# Create data directory
# Note: In distroless, directories must be created in the Kubernetes manifest
# or via an init container. The nonroot user (65532) will be used.

# Expose ports
# P2P: 8333 (mainnet), 18333 (testnet), 38333 (signet), 18444 (regtest)
# RPC: 8332 (mainnet), 18332 (testnet), 38332 (signet), 18443 (regtest)
# ZMQ: 28332, 28333
EXPOSE 8332 8333 18332 18333 38332 38333 18443 18444 28332 28333

# The distroless nonroot image runs as UID 65532
# This is set by the base image, but we document it here
# USER 65532:65532

# Health check using bitcoin-cli
# Note: HEALTHCHECK is not supported in distroless, use Kubernetes probes instead

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/bitcoind"]

# Default command - print to console for container logging
CMD ["-printtoconsole=1", "-server=1"]
