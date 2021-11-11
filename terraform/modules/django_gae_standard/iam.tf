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
