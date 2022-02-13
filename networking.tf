resource "google_compute_network" "minecraft" {
  project                 = data.google_project.minecraft.project_id
  name                    = "minecraft"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "core" {
  project       = data.google_project.minecraft.project_id
  name          = "core"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.minecraft.id
}

resource "google_compute_firewall" "minecraft_client" {
  project = data.google_project.minecraft.project_id
  name    = "minecraft-client"
  network = google_compute_network.minecraft.name

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }

  # For better control, consider limiting the source range
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft"]
}

# Whitelist IAP Tunnel for SSH
# https://cloud.google.com/iap/docs/using-tcp-forwarding
resource "google_compute_firewall" "minecraft_iap_tunnel" {
  project = data.google_project.minecraft.project_id
  name    = "minecraft-iap-tunnel"
  network = google_compute_network.minecraft.name
  allow {
    protocol = "tcp"
    ports = [
      "22",
    ]
  }
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["minecraft"]
}

resource "google_project_iam_binding" "minecraft_iap_tunnel" {
  project = data.google_project.minecraft.id
  role    = "roles/iap.tunnelResourceAccessor"
  members = [
    "user:${var.gcp_admin}",
    "serviceAccount:${local.terraform_sa.email}",
  ]
}
