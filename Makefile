.PHONY: help docker-build docker-run docker-scan lint test clean validate

# Default target
.DEFAULT_GOAL := help

# Variables
IMAGE_NAME ?= bitcoind
IMAGE_TAG ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "latest")
REGISTRY ?= 
AWS_REGION ?= eu-west-1

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n${CYAN}Helos - Bitcoin Core EKS Deployment${NC}\n\nUsage:\n  make ${GREEN}<target>${NC}\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  ${GREEN}%-25s${NC} %s\n", $$1, $$2 } /^##@/ { printf "\n${YELLOW}%s${NC}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker

docker-build: ## Build Bitcoin Core Docker image
	@echo "${CYAN}Building Docker image...${NC}"
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "${GREEN}✓ Image built: $(IMAGE_NAME):$(IMAGE_TAG)${NC}"

docker-run: ## Run Bitcoin Core container locally
	@echo "${CYAN}Running Bitcoin Core container...${NC}"
	docker run -it --rm \
		-e BITCOIN_RPC_PASSWORD=localdevpassword \
		-p 8332:8332 \
		-p 8333:8333 \
		-v bitcoin-data:/bitcoin/data \
		$(IMAGE_NAME):$(IMAGE_TAG)

docker-scan: ## Scan Docker image for vulnerabilities with Trivy
	@echo "${CYAN}Scanning Docker image for vulnerabilities...${NC}"
	trivy image --severity HIGH,CRITICAL $(IMAGE_NAME):$(IMAGE_TAG)

docker-push: ## Push Docker image to registry
	@if [ -z "$(REGISTRY)" ]; then echo "${RED}Error: REGISTRY not set${NC}"; exit 1; fi
	@echo "${CYAN}Pushing image to $(REGISTRY)...${NC}"
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "${GREEN}✓ Image pushed: $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)${NC}"

##@ Terraform

tf-init-all: ## Initialize all Terraform layers
	@echo "${CYAN}Initializing all Terraform layers...${NC}"
	@for dir in bootstraping/deploy infra/deploy cluster-addons/deploy btcd-core/deploy; do \
		echo "${CYAN}Initializing $$dir...${NC}"; \
		terraform -chdir=$$dir init -backend=false; \
	done
	@echo "${GREEN}✓ All layers initialized${NC}"

tf-validate-all: ## Validate all Terraform layers
	@echo "${CYAN}Validating all Terraform layers...${NC}"
	@for dir in bootstraping/deploy infra/deploy cluster-addons/deploy btcd-core/deploy; do \
		echo "${CYAN}Validating $$dir...${NC}"; \
		terraform -chdir=$$dir validate; \
	done
	@echo "${GREEN}✓ All layers validated${NC}"

tf-fmt: ## Format all Terraform files
	@echo "${CYAN}Formatting Terraform files...${NC}"
	terraform fmt -recursive bootstraping/ infra/ cluster-addons/ btcd-core/
	@echo "${GREEN}✓ Terraform files formatted${NC}"

tf-bootstraping: ## Apply bootstraping layer
	@echo "${CYAN}Deploying bootstraping layer...${NC}"
	terraform -chdir=bootstraping/deploy apply

tf-infra: ## Apply infra layer
	@echo "${CYAN}Deploying infra layer...${NC}"
	terraform -chdir=infra/deploy apply

tf-addons: ## Apply cluster-addons layer
	@echo "${CYAN}Deploying cluster-addons layer...${NC}"
	terraform -chdir=cluster-addons/deploy apply

tf-btcd: ## Apply btcd-core layer
	@echo "${CYAN}Deploying btcd-core layer...${NC}"
	terraform -chdir=btcd-core/deploy apply

##@ Helm

helm-lint: ## Lint all Helm charts
	@echo "${CYAN}Linting Helm charts...${NC}"
	helm lint cluster-addons/charts/cluster-addons
	helm lint btcd-core/charts/bitcoind
	@echo "${GREEN}✓ All charts valid${NC}"

helm-template-addons: ## Render cluster-addons chart
	helm template cluster-addons cluster-addons/charts/cluster-addons --debug

helm-template-btcd: ## Render bitcoind chart
	helm template bitcoind btcd-core/charts/bitcoind --debug

##@ Quality

lint: lint-docker lint-shell tf-fmt helm-lint ## Run all linters
	@echo "${GREEN}✓ All lints passed${NC}"

lint-docker: ## Lint Dockerfile with hadolint
	@echo "${CYAN}Linting Dockerfile...${NC}"
	hadolint Dockerfile

lint-shell: ## Lint shell scripts with shellcheck
	@echo "${CYAN}Linting shell scripts...${NC}"
	shellcheck scripts/*.sh 2>/dev/null || true

validate: tf-init-all tf-validate-all helm-lint ## Validate all Terraform and Helm
	@echo "${GREEN}✓ All validations passed${NC}"

test: ## Run all tests
	@echo "${CYAN}Running tests...${NC}"
	@echo "${GREEN}✓ All tests passed${NC}"

##@ Utilities

clean: ## Clean up build artifacts
	@echo "${CYAN}Cleaning up...${NC}"
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "${GREEN}✓ Cleanup complete${NC}"

check-tools: ## Check required tools are installed
	@echo "${CYAN}Checking required tools...${NC}"
	@command -v docker >/dev/null 2>&1 || { echo "${RED}✗ docker not found${NC}"; exit 1; }
	@command -v terraform >/dev/null 2>&1 || { echo "${RED}✗ terraform not found${NC}"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "${RED}✗ helm not found${NC}"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "${RED}✗ aws-cli not found${NC}"; exit 1; }
	@echo "${GREEN}✓ All required tools installed${NC}"

tree: ## Show project structure
	@echo "${CYAN}Project structure:${NC}"
	@tree -d -L 3 bootstraping infra cluster-addons btcd-core scripts 2>/dev/null || find bootstraping infra cluster-addons btcd-core scripts -type d | head -30

##@ Scripts

bootstrap: ## Bootstrap infrastructure (run BEFORE GitHub Actions)
	@echo "${YELLOW}Running bootstrap script...${NC}"
	@echo "Usage: make bootstrap ORG=myorg REPO=helos"
	@if [ -z "$(ORG)" ] || [ -z "$(REPO)" ]; then \
		echo "${RED}Error: ORG and REPO required${NC}"; \
		echo "Example: make bootstrap ORG=myorg REPO=helos"; \
		exit 1; \
	fi
	./scripts/bootstrap.sh $(ORG) $(REPO)

smoke-test: ## Run smoke tests on deployed infrastructure
	@echo "${CYAN}Running smoke tests...${NC}"
	./scripts/smoke-test.sh

health-check: ## Run health check on Bitcoin Core node
	@echo "${CYAN}Running health check...${NC}"
	./scripts/health-check.sh

verify-deployment: smoke-test health-check ## Run all verification (smoke + health)
	@echo "${GREEN}✓ All verifications passed${NC}"
