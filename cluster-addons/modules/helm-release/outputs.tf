output "release_name" {
  description = "Helm release name"
  value       = try(module.helm_release.metadata[0].name, null)
}

output "release_namespace" {
  description = "Helm release namespace"
  value       = try(module.helm_release.metadata[0].namespace, null)
}

output "metadata" {
  description = "Release metadata"
  value       = module.helm_release.metadata
}
