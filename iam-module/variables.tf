# Input Variables for IAM Module

variable "name" {
  description = "Base name for all IAM resources (role, policy, group, user)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_+=,.@-]*$", var.name))
    error_message = "Name must start with a letter and contain only valid IAM characters."
  }
}

variable "path" {
  description = "IAM path for all resources"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$", var.path)) || var.path == "/"
    error_message = "Path must start and end with forward slash."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
