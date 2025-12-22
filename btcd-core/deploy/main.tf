#------------------------------------------------------------------------------#
# Deploy Bitcoin Core via Helm
# -----------------------------------------------------------------------------#
module "btcd_core" {

  source  = "cloudposse/helm-release/aws"
  version = "v0.10.1"

  # helm release settings
  atomic                    = true
  cleanup_on_fail           = true
  timeout                   = 300
  wait                      = true
  name                      = "btcd-core"
  create_namespace          = var.namespace
  service_account_name      = var.service_account_name
  service_account_namespace = var.namespace
  kubernetes_namespace      = var.namespace

  eks_cluster_oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

  chart         = "${path.module}/../charts/bitcoind"
  chart_version = "1.0.0"

  values = [
    yamlencode({
      image = {
        repository = data.terraform_remote_state.infra.outputs.ecr_repository_url
        tag        = var.image_tag
      }
      namespace = var.namespace
      serviceAccount = {
        name = var.service_account_name
      }
      bitcoin = {
        network        = var.bitcoin_network
        rpcUser        = var.bitcoin_rpc_user
        txindex        = var.bitcoin_txindex
        prune          = var.bitcoin_prune
        dbCacheMB      = var.bitcoin_db_cache_mb
        maxConnections = var.bitcoin_max_connections
      }
      resources = var.resources
      persistence = {
        enabled      = true
        storageClass = var.storage_class
        size         = var.storage_size
      }
    })
  ]

  tags = var.default_tags

}
