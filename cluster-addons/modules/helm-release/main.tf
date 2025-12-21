# Helm Release Module - Wrapper for cloudposse/terraform-aws-helm-release

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }
  }
}

module "helm_release" {
  source  = "cloudposse/helm-release/aws"
  version = "~> 0.10.1"

  name      = var.name
  chart     = var.chart_path
  namespace = var.namespace

  create_namespace                 = var.create_namespace
  create_namespace_with_kubernetes = var.create_namespace_with_kubernetes

  repository    = var.repository
  chart_version = var.chart_version

  values = var.values

  # IRSA configuration
  iam_role_enabled            = var.iam_role_enabled
  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url
  service_account_name        = var.service_account_name

  # Helm options
  atomic          = var.atomic
  wait            = var.wait
  timeout         = var.timeout
  cleanup_on_fail = var.cleanup_on_fail

  context = module.this.context
}

module "this" {
  source  = "cloudposse/label/null"
  version = "~> 0.25"

  enabled   = var.enabled
  namespace = var.label_namespace
  name      = var.name

  tags = var.tags
}
