# Helm Release Module - Wrapper for cloudposse/terraform-aws-helm-release

module "helm_release" {
  source  = "cloudposse/helm-release/aws"
  version = "0.9.1"

  repository    = var.repository
  chart         = var.chart
  chart_version = var.chart_version

  create_namespace_with_kubernetes = var.create_namespace
  kubernetes_namespace             = var.kubernetes_namespace
  service_account_namespace        = var.kubernetes_namespace
  service_account_name             = var.service_account_name
  iam_role_enabled                 = var.iam_role_enabled

  eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  timeout         = var.timeout
  wait            = var.wait

  values = var.values

  context = module.this.context
}
