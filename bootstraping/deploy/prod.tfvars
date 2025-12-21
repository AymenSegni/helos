# Production Environment - Bootstraping Layer

github_org  = "AymenSegni"
github_repo = "helos"

gha_role_name          = "helos-prod-github-actions"
attach_admin_policy    = false
tfstate_bucket_name    = "helos-prod-tfstate"
tfstate_dynamodb_table = "helos-prod-tflock"

default_tags = {
  Project     = "helos"
  Environment = "prod"
  ManagedBy   = "terraform"
}
