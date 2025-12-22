# Bitcoin Core Layer - Main Module
# Deploys Bitcoin Core via Helm

# Deploy Bitcoin Core via Helm
module "bitcoind" {
  source = "../modules/helm-release"

  name       = "bitcoind"
  chart_path = "${path.module}/../charts/bitcoind"
  namespace  = var.namespace

  create_namespace            = false # Created by cluster-addons
  eks_cluster_oidc_issuer_url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

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
