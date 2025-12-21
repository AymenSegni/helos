#!/usr/bin/env bash
#
# Bootstrap the Helos infrastructure
# This script must be run BEFORE the GitHub Actions pipeline
# because it creates the OIDC role and S3 state backend.
#
# Usage: ./scripts/bootstrap.sh <github_org> <github_repo> [environment]
# Example: ./scripts/bootstrap.sh myorg helos dev
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Parse arguments
GITHUB_ORG="${1:-}"
GITHUB_REPO="${2:-}"
ENVIRONMENT="${3:-dev}"  # Default to dev

if [[ -z "${GITHUB_ORG}" ]] || [[ -z "${GITHUB_REPO}" ]]; then
    log_error "Usage: $0 <github_org> <github_repo> [environment]"
    log_error "Example: $0 myorg helos dev"
    log_error "         $0 myorg helos prod"
    exit 1
fi

log_info "============================================"
log_info " Helos Bootstraping - $(echo $ENVIRONMENT | tr "[:lower:]" "[:upper:]")"
log_info "============================================"
log_info "GitHub Org:  ${GITHUB_ORG}"
log_info "GitHub Repo: ${GITHUB_REPO}"
log_info "Environment: ${ENVIRONMENT}"
log_info ""

# Check AWS credentials
log_info "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    log_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="${AWS_REGION:-eu-west-1}"
log_success "AWS Account: ${AWS_ACCOUNT_ID}"
log_success "AWS Region: ${AWS_REGION}"

# Navigate to bootstraping directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_DIR="${SCRIPT_DIR}/../bootstraping/deploy"
TFVARS_FILE="${BOOTSTRAP_DIR}/${ENVIRONMENT}.tfvars"

if [[ ! -d "${BOOTSTRAP_DIR}" ]]; then
    log_error "Bootstraping directory not found: ${BOOTSTRAP_DIR}"
    exit 1
fi

if [[ ! -f "${TFVARS_FILE}" ]]; then
    log_error "tfvars file not found: ${TFVARS_FILE}"
    exit 1
fi

cd "${BOOTSTRAP_DIR}"
log_info "Working directory: $(pwd)"
log_info "Using tfvars: ${ENVIRONMENT}.tfvars"

# Initialize Terraform (local backend for bootstrap)
log_info "Initializing Terraform..."
terraform init -reconfigure

# Plan
log_info "Planning Terraform changes..."
terraform plan \
    -var="github_org=${GITHUB_ORG}" \
    -var="github_repo=${GITHUB_REPO}" \
    -var="aws_region=${AWS_REGION}" \
    -var-file="${ENVIRONMENT}.tfvars" \
    -out=tfplan

# Confirm
echo ""
log_warn "Review the plan above."
read -p "Apply these changes? (yes/no): " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
    log_warn "Aborted."
    exit 0
fi

# Apply
log_info "Applying Terraform changes..."
terraform apply tfplan

# Get outputs
log_info ""
log_success "============================================"
log_success " Bootstraping Complete! ($(echo $ENVIRONMENT | tr "[:lower:]" "[:upper:]"))"
log_success "============================================"
log_info ""
log_info "Add this as a GitHub repository SECRET:"
echo ""
echo "  AWS_OIDC_ROLE_ARN_$(echo $ENVIRONMENT | tr "[:lower:]" "[:upper:]") = $(terraform output -raw gha_role_arn)"
echo ""
log_info "S3 Backend configured:"
echo "  Bucket: $(terraform output -raw tfstate_bucket_name)"
echo "  DynamoDB Table: $(terraform output -raw tfstate_dynamodb_table)"
echo ""
log_info "Update backend-config in workflows to use:"
echo "  -backend-config=\"bucket=$(terraform output -raw tfstate_bucket_name)\""
echo "  -backend-config=\"dynamodb_table=$(terraform output -raw tfstate_dynamodb_table)\""
echo ""
log_success "You can now run the GitHub Actions pipeline!"
