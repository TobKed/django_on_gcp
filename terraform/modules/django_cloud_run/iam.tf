locals {
  google_cloud_build_default_service_account = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account" "cloud_run_service_account" {
  account_id   = var.cloud_run_service_account_name
  display_name = "Cloud Run Service Account"
}

resource "google_storage_bucket_iam_binding" "storage_object_admin" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]

  depends_on = [google_service_account.cloud_run_service_account]
}

resource "google_project_iam_binding" "secret_manager_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]

  depends_on = [
    google_project_service.gcp_services,
    google_service_account.cloud_run_service_account
  ]
}

resource "google_project_iam_binding" "run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]

  depends_on = [google_service_account.cloud_run_service_account]
}

resource "google_project_iam_binding" "run_admin" {
  project = var.project_id
  role    = "roles/run.admin"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]

  depends_on = [google_project_service.gcp_services]
}

resource "google_project_iam_binding" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}",
  ]

  depends_on = [google_project_service.gcp_services]
}

resource "google_project_iam_binding" "cloudsql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]

  depends_on = [google_service_account.cloud_run_service_account]
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.cloud_run_service_account.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${local.google_cloud_build_default_service_account}"
  ]

  depends_on = [google_project_service.gcp_services]
}
