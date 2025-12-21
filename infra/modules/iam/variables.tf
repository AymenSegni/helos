variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "bitcoin-prod"
}

variable "service_account_name" {
  description = "Kubernetes service account name"
  type        = string
  default     = "bitcoind"
}

variable "secrets_arns" {
  description = "ARNs of secrets the role can access"
  type        = list(string)
  default     = []
}

variable "additional_policy_arns" {
  description = "Additional IAM policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
