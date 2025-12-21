output "gha_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.gha_oidc.role_arn
}

output "tfstate_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3_tfstate.bucket_name
}

output "tfstate_dynamodb_table" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.s3_tfstate.dynamodb_table_name
}
