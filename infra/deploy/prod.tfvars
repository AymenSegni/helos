# Production Environment - Infrastructure Layer

aws_region   = "eu-west-1"
cluster_name = "helos-prod"

# VPC
vpc_cidr           = "10.1.0.0/16"
availability_zones = 3
single_nat_gateway = false # HA for prod

# EKS
cluster_version           = "1.31"
endpoint_public_access    = true
enabled_log_types         = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
cloudwatch_retention_days = 90

# Nodes - larger for prod
node_ami_type       = "BOTTLEROCKET_x86_64"
node_instance_types = ["m5.large", "m5.xlarge"]
node_min_size       = 2
node_max_size       = 5
node_desired_size   = 2

# ECR
ecr_repository_name = "bitcoind"
ecr_max_image_count = 50

default_tags = {
  Project     = "helos"
  Environment = "prod"
  ManagedBy   = "terraform"
}

# Enable taint in prod so only Bitcoin pods run on bitcoin nodes
enable_bitcoin_taint = true
