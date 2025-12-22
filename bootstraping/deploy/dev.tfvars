# Development Environment - Bootstraping Layer

github_org  = "AymenSegni"
github_repo = "helos"

gha_role_name          = "helos-dev-github-actions"
attach_admin_policy    = true #TODO: better to specify least privilege policies
tfstate_bucket_name    = "helos-dev-tfstate"
tfstate_dynamodb_table = "helos-dev-tflock"

default_tags = {
  Project     = "helos"
  Environment = "dev"
  ManagedBy   = "terraform"
}
