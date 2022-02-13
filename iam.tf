locals {
  minecraft_vm_power_role = "minecraft-vm-power"
  minecraft_admin_roles = [
    "roles/logging.viewer",
    "roles/compute.viewer",
  ]
}

resource "random_id" "minecraft_vm_power_role_suffix" {
  byte_length = 2
}

resource "google_project_iam_custom_role" "minecraft_vm_power" {
  project     = data.google_project.minecraft.project_id
  role_id     = "${title(replace(local.minecraft_vm_power_role, "-", ""))}${random_id.minecraft_vm_power_role_suffix.hex}"
  title       = title(replace(local.minecraft_vm_power_role, "-", " "))
  description = "Role that allows turn on and off VM(s)."
  permissions = [
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.get",
  ]
}

resource "google_compute_instance_iam_binding" "minecraft_vm_power" {
  project       = data.google_project.minecraft.project_id
  zone          = google_compute_instance.minecraft.zone
  instance_name = google_compute_instance.minecraft.name
  role          = google_project_iam_custom_role.minecraft_vm_power.id
  members       = toset(var.gcp_vm_power_members)
}

resource "google_project_iam_member" "minecraft_project_admin" {
  for_each = {
    for binding in setproduct(var.gcp_vm_power_members, local.minecraft_admin_roles) : "${binding[0]}_${binding[1]}" => {
      member = binding[0]
      role   = binding[1]
    }
  }
  project = data.google_project.minecraft.id
  role    = each.value.role
  member  = each.value.member
}
