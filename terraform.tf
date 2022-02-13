terraform {
  required_providers {
    google = {
      version = "~> 4.7.0"
    }
    random = {
      version = "~> 3.1.0"
    }
    template = {
      version = "~> 2.2.0"
    }
    google-beta = {
      version = "~> 4.7.0"
    }
  }

  backend "gcs" {
    bucket = "..."
    prefix = "core"
  }
}

provider "google" {
  user_project_override = true
  billing_project       = "..."
}

data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "..."
    prefix = "bootstrap"
  }
}
