# Helm Release Variables

variable "repository" {
  type        = string
  description = "Repository URL where to locate the requested chart"
  default     = null
}

variable "chart" {
  type        = string
  description = "Chart name to be installed. Can be local path, URL, or chart name if repository is specified"
}

variable "chart_version" {
  type        = string
  description = "Specify the exact chart version to install"
  default     = null
}

variable "create_namespace" {
  type        = bool
  description = "If true, the namespace will be created"
  default     = true
}

variable "kubernetes_namespace" {
  type        = string
  description = "The namespace to install the release into"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes ServiceAccount name"
  default     = null
}

variable "iam_role_enabled" {
  type        = bool
  description = "Whether to create an IAM role for IRSA"
  default     = false
}

variable "eks_cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL for the EKS cluster"
}

variable "atomic" {
  type        = bool
  description = "If set, installation process purges chart on fail"
  default     = true
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  default     = true
}

variable "timeout" {
  type        = number
  description = "Time in seconds to wait for any individual kubernetes operation"
  default     = 300
}

variable "wait" {
  type        = bool
  description = "Will wait until all resources are in a ready state before marking the release as successful"
  default     = true
}

variable "values" {
  type        = any
  description = "List of values in raw yaml to pass to helm"
  default     = null
}
