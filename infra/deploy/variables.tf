variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "helos"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}

# VPC
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Number of availability zones"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use single NAT gateway"
  type        = bool
  default     = true
}

# EKS
variable "endpoint_public_access" {
  description = "Enable public API endpoint"
  type        = bool
  default     = true
}

variable "enabled_log_types" {
  description = "EKS log types"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "cloudwatch_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 30
}

variable "node_ami_type" {
  description = "Node AMI type"
  type        = string
  default     = "BOTTLEROCKET_x86_64"
}

variable "node_instance_types" {
  description = "Node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_desired_size" {
  type    = number
  default = 1
}

# ECR
variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "bitcoind"
}

variable "ecr_image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "ecr_scan_on_push" {
  type    = bool
  default = true
}

variable "ecr_enable_lifecycle_policy" {
  type    = bool
  default = true
}

variable "ecr_max_image_count" {
  type    = number
  default = 30
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    Project   = "helos"
    ManagedBy = "terraform"
  }
}

variable "enable_bitcoin_taint" {
  description = "Enable taint on bitcoin node group"
  type        = bool
  default     = false
}

# EKS Cluster Access - passed from GHA secrets via TF_VAR_*
variable "aws_account_id" {
  description = "AWS Account ID (passed from GHA secrets)"
  type        = string
}

variable "gha_oidc_role_arn" {
  description = "ARN of the GitHub Actions OIDC role for cluster access"
  type        = string
}

variable "tf_user_arn" {
  description = "ARN of Aymen's CLI user (tf-0) for local cluster access"
  type        = string
}
