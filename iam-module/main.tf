# Task 6: Simple IAM Module
#
# Creates four IAM resources with consistent naming:
# - Role (assumable by identities in same account)
# - Policy (allows sts:AssumeRole on the role)
# - Group (with the policy attached)
# - User (added to the group)

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# ============================================================
# IAM Role
# Assumable by identities in the same account
# ============================================================
resource "aws_iam_role" "this" {
  name = var.name
  path = var.path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action    = "sts:AssumeRole"
        Condition = {}
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.name
  })
}

# ============================================================
# IAM Policy
# Allows sts:AssumeRole on the created role
# ============================================================
resource "aws_iam_policy" "assume_role" {
  name        = "${var.name}-assume-role"
  path        = var.path
  description = "Allows assuming the ${var.name} role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.this.arn
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-assume-role"
  })
}

# ============================================================
# IAM Group
# With the assume role policy attached
# ============================================================
resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "assume_role" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.assume_role.arn
}

# ============================================================
# IAM User
# Added to the group
# ============================================================
resource "aws_iam_user" "this" {
  name = var.name
  path = var.path

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_iam_user_group_membership" "this" {
  user   = aws_iam_user.this.name
  groups = [aws_iam_group.this.name]
}
