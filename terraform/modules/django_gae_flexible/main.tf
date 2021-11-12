provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_project" "project" {
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "sqladmin.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = var.project_id
  service  = each.key
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.region
}
