resource "google_service_account" "tf" {
  project      = google_project.minecraft.project_id
  account_id   = "github-terraform-pipeline"
  display_name = "Terraform pipeline service account"

  description = <<EOF
    All powerful terraform service account, use to automatically perform CI/CD actions.
  EOF
}

resource "google_storage_bucket" "state" {
  project                     = google_project_service.minecraft["storage.googleapis.com"].project
  name                        = "${var.gcp_tf_state_bucket}-${random_id.minecraft_project_suffix.hex}"
  location                    = var.gcp_region
  uniform_bucket_level_access = true

  force_destroy = true

  versioning {
    enabled = true
  }
  # This is a cost saving measure to only keep two versions of the state
  # It is also important to note that the state lock will always be versioned despite having multiple versions of the lock being useless.
  lifecycle_rule {
    condition {
      num_newer_versions = 2
    }
    action {
      type = "Delete"
    }
  }

  labels = local.common_labels
}

data "google_iam_policy" "state_admin" {
  binding {
    role = "roles/storage.admin"
    members = [
      "user:${var.gcp_admin}",
      "serviceAccount:${google_service_account.tf.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "state_admin" {
  bucket      = google_storage_bucket.state.name
  policy_data = data.google_iam_policy.state_admin.policy_data
}

resource "google_billing_account_iam_member" "billing_user" {
  billing_account_id = var.gcp_billing_account
  role               = "roles/billing.admin"
  member             = "serviceAccount:${google_service_account.tf.email}"
}

locals {
  project_admin_roles = [
    "roles/resourcemanager.projectIamAdmin",
    "roles/monitoring.editor",
    "roles/compute.instanceAdmin.v1",
    "roles/compute.imageUser",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.roleAdmin", # required for role creations
    "roles/storage.admin",
  ]
}

resource "google_project_iam_binding" "project_admin" {
  for_each = toset(local.project_admin_roles)
  project  = google_project.minecraft.id
  role     = each.key
  members = [
    "user:${var.gcp_admin}",
    "serviceAccount:${google_service_account.tf.email}"
  ]
}
