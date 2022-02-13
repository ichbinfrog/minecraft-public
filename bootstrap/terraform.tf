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

  # TODO: uncomment after initial bootstrap
  # to perform migration from local to GCS state bucket
  # backend "gcs" {
  #   bucket = "..."
  #   prefix = "bootstrap"
  # }
}
