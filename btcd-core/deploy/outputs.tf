output "release_name" {
  description = "Helm release name"
  value       = module.bitcoind.release_name
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = var.namespace
}
