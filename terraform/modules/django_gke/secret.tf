resource "google_secret_manager_secret" "django_settings" {
  secret_id  = var.django_settings_name
  depends_on = [google_project_service.gcp_services]
  labels = {
    label = "django_settings"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "django_settings_version" {
  secret = google_secret_manager_secret.django_settings.id

  #  for debugging purposes you may want to add DEBUG=True
  secret_data = <<-EOF
  SECRET_KEY=${var.django_secret_key}
  DATABASE_URL=postgres://${var.sql_user}:${var.sql_password}@//cloudsql/${var.project_id}:${var.region}:${google_sql_database_instance.database.name}/${google_sql_database.database.name}
  GS_BUCKET_NAME=${var.gcs_bucket_name}
  EOF
}

resource "google_service_account_key" "gke_cloud_sql_service_account_key" {
  service_account_id = google_service_account.gke_cloud_sql_service_account.name
}

resource "kubernetes_secret" "cloudsql_oauth_credentials" {
  metadata {
    name = "cloudsql-oauth-credentials"
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.gke_cloud_sql_service_account_key.private_key)
  }
}
