terraform {
  required_version = ">= 1.3"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.74.0, < 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.74.0, < 5.0"

    }

  }

  # backend "gcs" {
  #   bucket      = "mystatefilehere" ## replace with a GCS bucket name
  #   prefix      = "tfdefaulttt/"
  #   # credentials = "var.serviceaccount"
  # }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-sql-db:postgresql/v16.1.0"
  }
  provider_meta "google-beta" {
    module_name = "blueprints/terraform/terraform-google-sql-db:postgresql/v16.1.0"
  }

}

provider "google" {
  project     = "endless-fire-408913"
  region      = "us-central1"
  # credentials = file("../creds.json")
}

