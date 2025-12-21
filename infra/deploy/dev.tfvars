# Development Environment - Infrastructure Layer

aws_region   = "eu-west-1"
cluster_name = "helos-dev"

# VPC
vpc_cidr           = "10.0.0.0/16"
availability_zones = 2
single_nat_gateway = true

# EKS
cluster_version           = "1.31"
endpoint_public_access    = true
enabled_log_types         = ["audit", "api"]
cloudwatch_retention_days = 3

# Nodes - smaller for dev
node_ami_type       = "BOTTLEROCKET_x86_64"
node_instance_types = ["t3.medium"]
node_min_size       = 1
node_max_size       = 2
node_desired_size   = 1

# ECR
ecr_repository_name = "bitcoind"
ecr_max_image_count = 10

default_tags = {
  Project     = "helos"
  Environment = "dev"
  ManagedBy   = "terraform"
}
