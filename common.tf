locals {
  common_labels = {
    "managed-by" = "terraform"
    "repo"       = "minecraft"
    "app"        = "minecraft"
  }

  region       = var.gcp_region
  admin        = var.gcp_admin
  terraform_sa = data.terraform_remote_state.core.outputs.terraform_sa
}

data "google_project" "minecraft" {
  project_id = data.terraform_remote_state.core.outputs.minecraft_project.project_id
}

data "google_billing_account" "self" {
  billing_account = var.gcp_billing_account
}
