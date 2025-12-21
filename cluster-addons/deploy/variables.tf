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

variable "service_account_annotations" {
  description = "Service account annotations (e.g., for IRSA)"
  type        = map(string)
  default     = {}
}

variable "create_storage_class" {
  description = "Create GP3 storage class"
  type        = bool
  default     = true
}

variable "enable_network_policies" {
  description = "Enable network policies"
  type        = bool
  default     = true
}

variable "enable_resource_quota" {
  description = "Enable resource quota"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    Project   = "helos"
    ManagedBy = "terraform"
  }
}
