variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "bitcoin-prod"
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
  default     = "bitcoind"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Bitcoin configuration
variable "bitcoin_network" {
  description = "Bitcoin network (mainnet, testnet, signet, regtest)"
  type        = string
  default     = "mainnet"
}

variable "bitcoin_rpc_user" {
  description = "RPC username"
  type        = string
  default     = "bitcoin"
}

variable "bitcoin_txindex" {
  description = "Enable transaction index"
  type        = bool
  default     = false
}

variable "bitcoin_prune" {
  description = "Prune setting (0 = full node)"
  type        = number
  default     = 0
}

variable "bitcoin_db_cache_mb" {
  description = "Database cache in MB"
  type        = number
  default     = 4096
}

variable "bitcoin_max_connections" {
  description = "Maximum peer connections"
  type        = number
  default     = 125
}

# Resources
variable "resources" {
  description = "Pod resources"
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = {
      cpu    = "1"
      memory = "4Gi"
    }
    limits = {
      cpu    = "4"
      memory = "8Gi"
    }
  }
}

# Storage
variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "gp3"
}

variable "storage_size" {
  description = "Storage size"
  type        = string
  default     = "600Gi"
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    Project   = "helos"
    ManagedBy = "terraform"
  }
}
