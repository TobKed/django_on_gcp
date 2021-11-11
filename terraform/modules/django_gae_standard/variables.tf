variable "project_id" {
  description = "Project id where app will be deployed"
  type        = string
}

variable "region" {
  description = "Region of the components"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone of the components"
  type        = string
  default     = "us-central1-a"
}

variable "django_secret_key" {
  description = "Django app secret key"
  type        = string
}

variable "django_settings_name" {
  description = "Django settings name"
  type        = string
  default     = "django_settings"
}

variable "sql_database_instance_name" {
  description = "SQL database instance name"
  type        = string
  default     = "database-instance"
}

variable "sql_database_name" {
  description = "SQL database name"
  type        = string
  default     = "database"
}

variable "sql_user" {
  description = "SQL database username"
  type        = string
}

variable "sql_password" {
  description = "SQL database password"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Name of existing Google Cloud Storage bucket (define if static files should be served from GCS)"
  type        = string
  default     = ""
}
