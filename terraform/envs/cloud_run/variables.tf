variable "project_id" {
  description = "Project id where app will be deployed"
  type        = string
}

variable "region" {
  description = "Region of the components"
  type        = string
  default     = "europe-central2"
}

variable "zone" {
  description = "Zone of the components"
  type        = string
  default     = "europe-central2-a"
}

variable "cloud_run_service_account_name" {
  description = "Name of the service account created for Cloud RUn app"
  type        = string
}

variable "sql_database_instance_name" {
  description = "SQL database instance name"
  type        = string
}

variable "sql_database_name" {
  description = "SQL database name"
  type        = string
}

variable "django_secret_key" {
  description = "Django app secret key"
  type        = string
}

variable "sql_user" {
  description = "SQL database username"
  type        = string
}

variable "sql_password" {
  description = "SQL database password"
  type        = string
}
