resource "google_sql_database_instance" "database" {
  name             = var.sql_database_instance_name
  database_version = "POSTGRES_13"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = var.sql_database_name
  instance = google_sql_database_instance.database.name

  # workaround for terraform-provider-google issue:
  # googleapi: Error 400: Invalid request: Failed to delete user root.
  # helpful hint in comment:
  # https://github.com/hashicorp/terraform-provider-google/issues/3820#issuecomment-573665424
  depends_on = [google_sql_user.sql_user]
}

resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.database.name
  name     = var.sql_user
  password = var.sql_password
}
