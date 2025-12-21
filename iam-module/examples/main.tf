# IAM Module - Example Usage
#
# This example demonstrates how to use the IAM module to create
# a role, policy, group, and user with consistent naming.

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "iam_resources" {
  source = "../"

  name = "bitcoin-operator"
  path = "/"

  tags = {
    Environment = "dev"
    Project     = "helos"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "role_arn" {
  value = module.iam_resources.role_arn
}

output "policy_arn" {
  value = module.iam_resources.policy_arn
}

output "group_name" {
  value = module.iam_resources.group_name
}

output "user_name" {
  value = module.iam_resources.user_name
}
