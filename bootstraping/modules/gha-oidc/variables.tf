variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-terraform"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "attach_admin_policy" {
  description = "Attach AdministratorAccess policy to the role"
  type        = bool
  default     = false
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
