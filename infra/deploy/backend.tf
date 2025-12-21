# S3 Backend Configuration
# Bucket and table created in bootstraping layer
# Configure via: terraform init -backend-config="bucket=helos-<env>-tfstate"

terraform {
  backend "s3" {
    key     = "infra/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
    # Configured via -backend-config:
    # bucket         = "helos-<env>-tfstate"
    # dynamodb_table = "helos-<env>-tflock"
  }
}
