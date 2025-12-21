# S3 Backend Configuration
# Bucket and table created in bootstraping layer

terraform {
  backend "s3" {
    key     = "cluster-addons/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
    # Configured via -backend-config:
    # bucket         = "helos-<env>-tfstate"
    # dynamodb_table = "helos-<env>-tflock"
  }
}
