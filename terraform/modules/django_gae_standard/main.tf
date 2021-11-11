
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_project" "project" {
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "appengine.googleapis.com",
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

resource "random_id" "random_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "database" {
  name             = "db-instance-${random_id.random_suffix.hex}"
  database_version = "POSTGRES_13"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = "db-${random_id.random_suffix.hex}"
  instance = google_sql_database_instance.database.name
}

resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.database.name
  name     = var.sql_user
  password = var.sql_password
}

resource "google_secret_manager_secret" "django_settings" {
  secret_id  = "django_settings"
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

  secret_data = <<-EOF
  DEBUG=True
  SECRET_KEY=${var.django_secret_key}
  DATABASE_URL=postgres://${var.sql_user}:${var.sql_password}@//cloudsql/${var.project_id}:${var.region}:${google_sql_database_instance.database.name}/${google_sql_database.database.name}
  EOF
}

data "google_iam_policy" "secret_manager_secret_accessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"

    members = [
      "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
      "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}

data "google_iam_policy" "app_engine_app_admin" {
  binding {
    role = "roles/appengine.appAdmin"

    members = [
      "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}

data "google_iam_policy" "cloudsql_admin" {
  binding {
    role = "roles/cloudsql.admin"

    members = [
      "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    ]
  }
}
