# Provider Configurations

provider "aws" {
  region = var.aws_region
}

# Get cluster info from infra layer
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "helos-${var.environment}-tfstate"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
