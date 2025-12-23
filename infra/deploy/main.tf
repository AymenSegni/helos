# Deploys VPC, EKS, and ECR

# VPC
module "vpc" {
  source = "../modules/vpc"

  name               = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  single_nat_gateway = var.single_nat_gateway
  tags               = var.default_tags
}

# EKS Cluster
module "eks" {
  source = "../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  intra_subnets   = module.vpc.intra_subnets

  endpoint_public_access    = var.endpoint_public_access
  enabled_log_types         = var.enabled_log_types
  cloudwatch_retention_days = var.cloudwatch_retention_days

  node_ami_type       = var.node_ami_type
  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size

  # Cluster access entries (AWS CAM)
  access_entries = {
    # Root account access
    root = {
      principal_arn = "arn:aws:iam::${var.aws_account_id}:root"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }

    # GitHub Actions OIDC role
    gha_oidc = {
      principal_arn = var.gha_oidc_role_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }

    # Aymen's CLI user (tf-0)
    tf_user = {
      principal_arn = var.tf_user_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  tags = var.default_tags
}

# ECR Repository
module "ecr" {
  source = "../modules/ecr"

  repository_name         = var.ecr_repository_name
  image_tag_mutability    = var.ecr_image_tag_mutability
  scan_on_push            = var.ecr_scan_on_push
  enable_lifecycle_policy = var.ecr_enable_lifecycle_policy
  max_image_count         = var.ecr_max_image_count

  tags = var.default_tags
}
