output "release_name" {
  description = "Helm release name"
  value       = module.cluster_addons.release_name
}

output "namespace" {
  description = "Namespace created"
  value       = var.namespace
}
