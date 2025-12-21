# Cluster Addons Layer - Main Module
# Deploys Kubernetes platform components via Helm

# Deploy cluster addons via Helm
module "cluster_addons" {
  source = "../modules/helm-release"

  name       = "cluster-addons"
  chart_path = "${path.module}/../charts/cluster-addons"
  namespace  = var.namespace

  create_namespace = false # Chart creates it

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
