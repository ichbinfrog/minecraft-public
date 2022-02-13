locals {
  common_labels = {
    "managed-by" = "terraform"
    "repo"       = "minecraft"
  }
}

data "google_billing_account" "self" {
  billing_account = var.gcp_billing_account
}

resource "random_id" "minecraft_project_suffix" {
  byte_length = 2
}

resource "google_project" "minecraft" {
  project_id          = "${var.gcp_project_name}-${random_id.minecraft_project_suffix.hex}"
  name                = title(replace(var.gcp_project_name, "-", " "))
  billing_account     = data.google_billing_account.self.id
  auto_create_network = false

  labels = local.common_labels
}

resource "google_project_service" "minecraft" {
  for_each = toset([
    "storage.googleapis.com",              # required for gcs
    "iamcredentials.googleapis.com",       # required for workload id federation
    "cloudresourcemanager.googleapis.com", # required for folder / project iam permissions
    "cloudbilling.googleapis.com",         # required for billing resources
    "billingbudgets.googleapis.com",       # required for billing budgets
    "monitoring.googleapis.com",           # required for monitoring channels
    "iam.googleapis.com",                  # required for creation of service account
    "logging.googleapis.com",              # required for logging export for gce
  ])
  project                    = google_project.minecraft.id
  service                    = each.key
  disable_dependent_services = true
}
