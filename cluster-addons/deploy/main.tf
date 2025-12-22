# Cluster Addons Layer - Main Module
# Deploys Kubernetes platform components via Helm

# Deploy cluster addons via Helm
module "cluster_addons" {
  source = "../modules/helm-release"

  chart                       = "${path.module}/../charts/cluster-addons"
  kubernetes_namespace        = var.namespace
  eks_cluster_oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  create_namespace = true # Chart creates it

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

