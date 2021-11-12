terraform {
  required_version = ">= 1.0.10"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "bucket" {
  name          = "${var.project_id}-media"
  location      = "EU"
  force_destroy = true
}

module "django_cloud_run" {
  source = "../../modules/django_cloud_run"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  django_secret_key              = var.django_secret_key
  sql_user                       = var.sql_user
  sql_password                   = var.sql_password
  sql_database_instance_name     = var.sql_database_instance_name
  gcs_bucket_name                = google_storage_bucket.bucket.name
  cloud_run_service_account_name = var.cloud_run_service_account_name
}
