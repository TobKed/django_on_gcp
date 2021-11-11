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
}

resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.database.name
  name     = var.sql_user
  password = var.sql_password
}
