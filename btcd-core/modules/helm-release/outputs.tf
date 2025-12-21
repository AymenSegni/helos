output "release_name" {
  description = "Helm release name"
  value       = var.enabled ? module.helm_release.release_name : null
}

output "release_namespace" {
  description = "Helm release namespace"
  value       = var.enabled ? module.helm_release.release_namespace : null
}

output "metadata" {
  description = "Release metadata"
  value       = var.enabled ? module.helm_release.metadata : null
}
