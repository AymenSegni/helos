variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "gha_role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "helos-github-actions"
}

variable "attach_admin_policy" {
  description = "Attach AdministratorAccess policy to GHA role"
  type        = bool
  default     = false
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to GHA role"
  type        = list(string)
  default     = []
}

variable "tfstate_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "helos-tfstate"
}

variable "tfstate_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "helos-tflock"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project   = "helos"
    ManagedBy = "terraform"
  }
}
