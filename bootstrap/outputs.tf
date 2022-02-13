output "minecraft_project" {
  description = "Full object of the google_project created"
  value       = google_project.minecraft
}

output "terraform_sa" {
  description = "Full object of the terraform google_service_account created"
  value       = google_service_account.tf
  sensitive   = true
}
