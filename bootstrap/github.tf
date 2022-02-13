
resource "google_iam_workload_identity_pool" "github" {
  provider                  = google-beta
  project                   = google_project_service.minecraft["iamcredentials.googleapis.com"].project
  workload_identity_pool_id = "github-pool"
  display_name              = "Github Terraform Pipeline"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  provider = google-beta
  project  = google_project.minecraft.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  description                        = "OIDC identity pool provider for terraform pipeline"
  disabled                           = false

  # For a list of claims: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
  # And it's counterpart in terraform: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider#attribute_mapping
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.repository"       = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "identity_federation_user" {
  service_account_id = google_service_account.tf.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "user:${var.gcp_admin}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github
  ]
}

resource "google_service_account_iam_member" "identity_federation_principalset" {
  service_account_id = google_service_account.tf.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_username}/${var.github_repo}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github
  ]
}
