# Production Environment - Bitcoin Core Layer

environment = "prod"
aws_region  = "eu-west-1"
namespace   = "bitcoin-prod"

service_account_name = "bitcoind"
image_tag            = "latest"

# Bitcoin configuration - mainnet for prod
bitcoin_network         = "mainnet"
bitcoin_rpc_user        = "bitcoin"
bitcoin_txindex         = false
bitcoin_prune           = 0 # Full node for prod
bitcoin_db_cache_mb     = 4096
bitcoin_max_connections = 125

# Production resources
resources = {
  requests = {
    cpu    = "1"
    memory = "4Gi"
  }
  limits = {
    cpu    = "4"
    memory = "8Gi"
  }
}

# Full mainnet storage
storage_class = "gp3"
storage_size  = "600Gi"

default_tags = {
  Project     = "helos"
  Environment = "prod"
  ManagedBy   = "terraform"
}
