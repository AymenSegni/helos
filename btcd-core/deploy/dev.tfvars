# Development Environment - Bitcoin Core Layer

environment = "dev"
aws_region  = "eu-west-1"
namespace   = "bitcoin-dev"

service_account_name = "bitcoind"
image_tag            = "latest"

# Bitcoin configuration - testnet for dev
bitcoin_network         = "testnet"
bitcoin_rpc_user        = "bitcoin"
bitcoin_txindex         = false
bitcoin_prune           = 550 # Pruned node for dev
bitcoin_db_cache_mb     = 1024
bitcoin_max_connections = 50

# Smaller resources for dev
resources = {
  requests = {
    cpu    = "500m"
    memory = "2Gi"
  }
  limits = {
    cpu    = "2"
    memory = "4Gi"
  }
}

# Smaller storage for dev (testnet)
storage_class = "gp3"
storage_size  = "50Gi"

default_tags = {
  Project     = "helos"
  Environment = "dev"
  ManagedBy   = "terraform"
}
