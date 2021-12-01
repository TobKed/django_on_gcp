locals {
  google_cloud_build_default_service_account = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

data "google_app_engine_default_service_account" "default" {
  depends_on = [google_project_service.gcp_services]
}

resource "google_project_iam_binding" "secret_manager_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${data.google_app_engine_default_service_account.default.email}",
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]
}

resource "google_project_iam_binding" "app_engine_app_admin" {
  project = var.project_id
  role    = "roles/appengine.appAdmin"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]
}

resource "google_project_iam_binding" "cloudsql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = data.google_app_engine_default_service_account.default.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]
}
