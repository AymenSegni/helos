# Development Environment - Cluster Addons Layer

environment = "dev"
aws_region  = "eu-west-1"
namespace   = "bitcoin-dev"

service_account_name        = "bitcoind"
service_account_annotations = {}

create_storage_class    = true
enable_network_policies = true
enable_resource_quota   = true

default_tags = {
  Project     = "helos"
  Environment = "dev"
  ManagedBy   = "terraform"
}
