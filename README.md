
# How to deploy Django application on Google Cloud Platform.



There are many ways to deploy Django application on GCP:

 - App Engine:
   - standard environment
   - flexible environment
 - Cloud Run
 - Kubernetes (maybe covered here, we will see)
 - Compute Engine (not covered here)



## App Engine - standard environment

Set environmental variables.
Some values you have to know by hard, like `PROJECT_ID`.
Other you can generate on fly, like `DJANGO_SECRET_KEY` however remember to keep them somewhere (see next step).
They will be used to provide input variables for terraform and for `gcloud` commands.

```bash
export PROJECT_ID=django-gae-tf-test-proj-2
export REGION=europe-central2
export ZONE=europe-central2-a
export SQL_DATABASE_INSTANCE_NAME="${PROJECT_ID}-db"

export DJANGO_SECRET_KEY=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 50 | head -n1)
export SQL_USER=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 10 | head -n1)
export SQL_PASSWORD=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 10 | head -n1)
```

```bash
gcloud config set project $PROJECT_ID
```

Terraform can read variables from environment variables.
Naming convention is `TF_VAR_variable_name`.

```bash
export TF_VAR_project_id=$PROJECT_ID
export TF_VAR_region=$REGION
export TF_VAR_zone=$ZONE
export TF_VAR_django_secret_key=$DJANGO_SECRET_KEY
export TF_VAR_sql_database_instance_name=$SQL_DATABASE_INSTANCE_NAME
export TF_VAR_sql_user=$SQL_USER
export TF_VAR_sql_password=$SQL_PASSWORD
```


Another way to provide input variables is `.tfvars` file.
With variables set in previous such file could be generated with following command:

```bash
cat << EOF > terraform.tfvars
project_id                 = "$PROJECT_ID"
region                     = "$REGION"
zone                       = "$ZONE"
django_secret_key          = "$DJANGO_SECRET_KEY"
sql_database_instance_name = "$SQL_DATABASE_INSTANCE_NAME"
sql_user                   = "$SQL_USER"
sql_password               = "$SQL_PASSWORD"
EOF
```


In my opinion when possible *Terraform* should be used to provide infrastructure only and
deployment of the application itself should be handled separately.

[Don’t Deploy Applications with Terraform - Paul Durivage](https://medium.com/google-cloud/dont-deploy-applications-with-terraform-2f4508a45987)


```bash
gcloud builds submit  \
    --project $PROJECT_ID \
    --config cloudbuild/gae_app_standard_deploy_cloudbuild.yaml \
    --substitutions _INSTANCE_NAME=$SQL_DATABASE_INSTANCE_NAME,_REGION=$REGION
```

## Warnings!

 1. Remember to edit `.gcloudignore`. It excludes all files except implicitly added.
