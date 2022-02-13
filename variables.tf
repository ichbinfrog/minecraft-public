variable "gcp_billing_account" {
  description = "The alphanumeric ID of the billing account this project belongs to"
  type        = string
  sensitive   = true
}

variable "gcp_project_name" {
  description = "GCP project name"
  type        = string
  default     = "minecraft"
}

variable "gcp_admin" {
  description = "GCP user admin's email"
  type        = string
}

variable "gcp_region" {
  description = "Region for the state bucket"
  type        = string
}

variable "github_username" {
  description = "Github username"
  type        = string
}

variable "github_repo" {
  description = "Github repo name"
  type        = string
}

variable "gcp_persistent_disk_zone" {
  description = "Zone where the persistent disk is created"
  type        = string
}

variable "gcp_persistent_disk_size" {
  type        = number
  description = "Size of the minecraft disk in GB"
  default     = 20
}

variable "gcp_persistent_disk_type" {
  type        = string
  description = "Minecraft data persistent disk type"
  default     = "pd-standard"
}

variable "gcp_vm_power_members" {
  description = "List of emails that can see and turn on/off the minecraft GCP VM instance"
  type        = list(string)
}

variable "gcp_machine_flavor" {
  description = "GCP machine flavor/type"
  type        = string
  default     = "n1-standard-1"
}

variable "gcp_machine_preemptible" {
  description = "GCP machine preemptibility"
  type        = bool
  default     = true
}

variable "gcp_tf_state_bucket" {
  description = "GCP bucket name that will hold Terraform state"
  type        = string
  default     = "tf-state"
}

variable "minecraft_container_env" {
  type = map(string)
  default = {
    "EULA" : "TRUE",
    "VERSION" : "1.18.1",
    "MAX_MEMORY" : "3G",
    "ENFORCE_WHITELIST" : "TRUE",
    "ONLINE_MODE" : "FALSE",
  }
}

variable "minecraft_image" {
  description = "Minecraft Docker image"
  type        = string
  default     = "itzg/minecraft-server:java17"
}
