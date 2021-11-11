variable "project_id" {
  description = "Project id where app will be deployed"
  type        = string
}

variable "region" {
  description = "Region of the components"
  type        = string
}

variable "zone" {
  description = "Zone of the components"
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
