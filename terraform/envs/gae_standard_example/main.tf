terraform {
  required_version = ">= 1.0.10"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "django_gae_standard" {
  source = "../../modules/django_gae_standard"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  django_secret_key = var.django_secret_key
  sql_user          = var.sql_user
  sql_password      = var.sql_password
}
