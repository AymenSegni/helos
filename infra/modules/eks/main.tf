# EKS Module

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  # Cluster access
  cluster_endpoint_public_access  = var.endpoint_public_access
  cluster_endpoint_private_access = true

  # OIDC for IRSA
  enable_irsa = true

  # Give Terraform identity admin access
  enable_cluster_creator_admin_permissions = true

  # Cluster access entries (AWS CAM)
  access_entries = var.access_entries

  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
  }

  # Logging
  cluster_enabled_log_types              = var.enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_retention_days

  # Managed Node Groups - Dedicated for Bitcoin Core (stable, no auto-scaling)
  eks_managed_node_groups = {
    # System node group for cluster services
    system = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        "node.kubernetes.io/purpose" = "system"
      }

      taints = []
    }

    # Dedicated Bitcoin Core node group - stable, long-running
    bitcoin = {
      ami_type       = var.node_ami_type
      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # Labels for node selection
      labels = {
        "node.kubernetes.io/purpose" = "bitcoin"
        "workload"                   = "stateful"
      }

      # Taint to ensure only Bitcoin pods run here
      taints = var.enable_bitcoin_taint ? [
        {
          key    = "dedicated"
          value  = "bitcoin"
          effect = "NO_SCHEDULE"
        }
      ] : []

      # Use on-demand instances (not spot) for stability
      capacity_type = "ON_DEMAND"

      # Larger root volume for blockchain data caching
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # Update config for safer rolling updates
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }

  tags = var.tags
}
