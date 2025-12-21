variable "enabled" {
  description = "Enable/disable the module"
  type        = bool
  default     = true
}

variable "name" {
  description = "Release name"
  type        = string
}

variable "chart_path" {
  description = "Path to local chart"
  type        = string
  default     = null
}

variable "repository" {
  description = "Helm repository URL"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Chart version"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "create_namespace" {
  description = "Create namespace"
  type        = bool
  default     = false
}

variable "create_namespace_with_kubernetes" {
  description = "Create namespace with kubernetes provider"
  type        = bool
  default     = false
}

variable "values" {
  description = "List of values in raw YAML"
  type        = list(string)
  default     = []
}

variable "iam_role_enabled" {
  description = "Enable IRSA"
  type        = bool
  default     = false
}

variable "eks_cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Service account name for IRSA"
  type        = string
  default     = null
}

variable "atomic" {
  description = "Atomic install"
  type        = bool
  default     = true
}

variable "wait" {
  description = "Wait for resources"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Timeout in seconds"
  type        = number
  default     = 300
}

variable "cleanup_on_fail" {
  description = "Cleanup on failure"
  type        = bool
  default     = true
}

variable "label_namespace" {
  description = "Label namespace"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
