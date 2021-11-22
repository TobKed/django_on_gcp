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

variable "sql_database_instance_name" {
  description = "SQL database instance name"
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
