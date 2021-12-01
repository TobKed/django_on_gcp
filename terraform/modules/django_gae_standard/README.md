<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_app_engine_application.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/app_engine_application) | resource |
| [google_project_iam_binding.app_engine_app_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.cloudsql_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.secret_manager_secret_accessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_service.gcp_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.django_settings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.django_settings_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account_iam_binding.admin-account-iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_sql_database.database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.sql_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_app_engine_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/app_engine_default_service_account) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_django_secret_key"></a> [django\_secret\_key](#input\_django\_secret\_key) | Django app secret key | `string` | n/a | yes |
| <a name="input_django_settings_name"></a> [django\_settings\_name](#input\_django\_settings\_name) | Django settings name | `string` | `"django_settings"` | no |
| <a name="input_gcp_service_list"></a> [gcp\_service\_list](#input\_gcp\_service\_list) | The list of apis necessary for the project | `list(string)` | <pre>[<br>  "secretmanager.googleapis.com",<br>  "cloudbuild.googleapis.com",<br>  "appengine.googleapis.com",<br>  "sqladmin.googleapis.com"<br>]</pre> | no |
| <a name="input_gcs_bucket_name"></a> [gcs\_bucket\_name](#input\_gcs\_bucket\_name) | Name of existing Google Cloud Storage bucket (define if static files should be served from GCS) | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id where app will be deployed | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of the components | `string` | `"us-central1"` | no |
| <a name="input_sql_database_instance_name"></a> [sql\_database\_instance\_name](#input\_sql\_database\_instance\_name) | SQL database instance name | `string` | `"database-instance"` | no |
| <a name="input_sql_database_name"></a> [sql\_database\_name](#input\_sql\_database\_name) | SQL database name | `string` | `"database"` | no |
| <a name="input_sql_password"></a> [sql\_password](#input\_sql\_password) | SQL database password | `string` | n/a | yes |
| <a name="input_sql_user"></a> [sql\_user](#input\_sql\_user) | SQL database username | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone of the components | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_google_sql_database_instance_name"></a> [google\_sql\_database\_instance\_name](#output\_google\_sql\_database\_instance\_name) | n/a |
| <a name="output_google_sql_database_name"></a> [google\_sql\_database\_name](#output\_google\_sql\_database\_name) | n/a |
<!-- END_TF_DOCS -->
