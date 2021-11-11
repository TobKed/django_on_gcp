locals {
  project_id = "django-gae-tf-test-proj"
  region     = "europe-west3"
  zone       = "europe-west3-a"
}

terraform {
  required_version = ">= 1.0.10"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

module "django_gae_standard" {
  source = "../../modules/django_gae_standard"

  project_id = local.project_id
  region     = local.region
  zone       = local.zone

  django_secret_key = random_password.secret.result
  sql_user          = random_string.user.result
  sql_password      = random_password.password.result
}
