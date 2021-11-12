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

module "django_gae_standard" {
  source = "../../modules/django_gae_flexible"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  django_secret_key          = var.django_secret_key
  sql_user                   = var.sql_user
  sql_password               = var.sql_password
  sql_database_instance_name = var.sql_database_instance_name
  gcs_bucket_name            = google_storage_bucket.bucket.name
}
