data "google_compute_image" "cos" {
  project = "cos-cloud"
  family  = "cos-93-lts"
}

resource "google_service_account" "minecraft" {
  project      = data.google_project.minecraft.project_id
  account_id   = "minecraft"
  display_name = "Minecraft compute instance service account"
}

resource "google_service_account_iam_binding" "terraform_minecraft_gce" {
  service_account_id = google_service_account.minecraft.name
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${local.terraform_sa.email}",
  ]
}

resource "google_project_iam_member" "minecraft_log_writer" {
  project = data.google_project.minecraft.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minecraft.email}"
}

resource "google_compute_resource_policy" "minecraft_data_snapshot" {
  name   = "minecraft-data-snapshot"
  region = var.gcp_persistent_disk_zone
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "00:00"
      }
    }
  }
}

resource "google_compute_disk" "minecraft" {
  project = data.google_project.minecraft.project_id
  name    = "minecraft-data"
  type    = var.gcp_persistent_disk_type
  zone    = var.gcp_persistent_disk_zone
  size    = var.gcp_persistent_disk_size

  labels = local.common_labels

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_address" "minecraft" {
  project      = data.google_project.minecraft.project_id
  name         = "minecraft-ip"
  region       = var.gcp_region
  network_tier = "PREMIUM"
}

locals {
  mount_dir = "/var/data"
}

data "template_file" "minecraft_cloud_init" {
  template = file("${path.module}/config/cloud-config.yaml")
  vars = {
    DEVICE_ID = "/dev/disk/by-id/google-sdb"
    MOUNT_DIR = local.mount_dir
  }
}

resource "google_compute_instance" "minecraft" {
  project      = data.google_project.minecraft.project_id
  name         = "minecraft"
  machine_type = var.gcp_machine_flavor
  zone         = var.gcp_persistent_disk_zone
  tags         = ["minecraft"]

  metadata = {
    enable-oslogin        = "TRUE"
    google-logging-enable = "TRUE"
    user-data             = data.template_file.minecraft_cloud_init.rendered
    startup-script = templatefile("${path.module}/config/startup.sh", {
      MOUNT_DIR     = local.mount_dir,
      CONTAINER_ENV = var.minecraft_container_env,
      IMAGE         = var.minecraft_image
    })
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = data.google_compute_image.cos.id
      type  = "pd-standard"
    }
  }

  attached_disk {
    source      = google_compute_disk.minecraft.self_link
    device_name = "sdb"
    mode        = "READ_WRITE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.core.self_link
    access_config {
      nat_ip = google_compute_address.minecraft.address
    }
  }

  allow_stopping_for_update = true
  service_account {
    email = google_service_account.minecraft.email
    scopes = [
      # https://cloud.google.com/compute/docs/access/service-accounts#accesscopesiam
      "userinfo-email",
      "logging-write",
    ]
  }

  scheduling {
    preemptible       = var.gcp_machine_preemptible
    automatic_restart = false
  }

  labels = local.common_labels
  depends_on = [
    google_service_account_iam_binding.terraform_minecraft_gce,
    google_project_iam_member.minecraft_log_writer,
  ]
}

resource "google_compute_instance_iam_binding" "minecraft" {
  project       = data.google_project.minecraft.project_id
  zone          = google_compute_instance.minecraft.zone
  instance_name = google_compute_instance.minecraft.name
  role          = "roles/compute.osLogin"
  members = [
    "user:${var.gcp_admin}",
  ]
}
