# Deploys GitHub Actions OIDC and S3 backend for Terraform state
# NOTE: This layer uses local backend initially, then can migrate to S3

# GitHub Actions OIDC
module "gha_oidc" {
  source = "../modules/gha-oidc"

  role_name           = var.gha_role_name
  github_org          = var.github_org
  github_repo         = var.github_repo
  attach_admin_policy = var.attach_admin_policy
  policy_arns         = var.policy_arns
  tags                = var.default_tags
}

# S3 Backend for Terraform State
module "s3_tfstate" {
  source = "../modules/s3-tfstate"

  bucket_name         = var.tfstate_bucket_name
  dynamodb_table_name = var.tfstate_dynamodb_table
  tags                = var.default_tags
}
