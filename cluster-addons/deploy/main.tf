#------------------------------------------------------------------------------#
# Deploy cluster addons via
# -----------------------------------------------------------------------------#

module "cluster_addons" {

  source  = "cloudposse/helm-release/aws"
  version = "v0.10.1"

  # helm release settings
  atomic                    = true
  cleanup_on_fail           = true
  timeout                   = 300
  wait                      = true
  name                      = "addons"
  create_namespace          = false
  service_account_name      = var.service_account_name
  service_account_namespace = var.namespace
  kubernetes_namespace      = var.namespace

  eks_cluster_oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  chart         = "${path.module}/../charts/cluster-addons"
  chart_version = "1.0.0"
  values = [
    yamlencode({
      namespace = {
        name = var.namespace
      }
      serviceAccount = {
        create      = true
        name        = var.service_account_name
        annotations = var.service_account_annotations
      }
      storageClass = {
        create = var.create_storage_class
      }
      networkPolicy = {
        enabled = var.enable_network_policies
      }
      resourceQuota = {
        enabled = var.enable_resource_quota
      }
    })
  ]

  tags = var.default_tags

}
