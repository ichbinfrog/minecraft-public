variable "gcp_billing_account" {
  description = "The alphanumeric ID of the billing account this project belongs to"
  type        = string
  sensitive   = true
}

variable "gcp_project_name" {
  description = "GCP project name. Will be suffixed by a random 4 character string"
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

variable "gcp_tf_state_bucket" {
  description = "GCP bucket name that will hold Terraform state. Will have the same random 4 character suffix as the project"
  type        = string
}
