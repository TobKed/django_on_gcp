
# How to deploy Django application on Google Cloud Platform.

## What and why


There are many ways to deploy Django application on GCP:

 - App Engine:
   - standard environment (without and with GCS storage)
   - flexible environment (with GCS storage)
 - Cloud Run (with GCS storage)
 - Kubernetes (maybe covered here, we will see)
 - Compute Engine (not covered here)

## Perequisites

Topics  with which you should be familiar with since they will be not covered here:

 - Google Cloud Platform: basics of the services, usage of `gcloud` CLI, managing billing
 - Terraform

## App Engine - standard environment

Set environmental variables.
Some values you have to know by hard, like `PROJECT_ID`.
Other you can generate on fly, like `DJANGO_SECRET_KEY` however remember to keep them somewhere (see next step).
They will be used to provide input variables for terraform and for `gcloud` commands.

```bash
export PROJECT_ID=django-gae-tf-test-proj-2
export REGION=europe-central2
export ZONE=europe-central2-a
export SQL_DATABASE_INSTANCE_NAME="${PROJECT_ID}-db-biss"
export SERVICE_NAME=polls-service
export SERVICE_ACCOUNT_NAME=polls-service-account  # for cloud run
export SERVICE_ACCOUNT="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"   # for cloud run

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
export TF_VAR_cloud_run_service_account_name=$SERVICE_ACCOUNT_NAME
```


Another way to provide input variables is `.tfvars` file.
With variables set in previous such file could be generated with following command:

```bash
cat << EOF > terraform.tfvars
project_id                     = "$PROJECT_ID"
region                         = "$REGION"
zone                           = "$ZONE"
django_secret_key              = "$DJANGO_SECRET_KEY"
sql_database_instance_name     = "$SQL_DATABASE_INSTANCE_NAME"
sql_user                       = "$SQL_USER"
sql_password                   = "$SQL_PASSWORD"
cloud_run_service_account_name = "$SERVICE_ACCOUNT_NAME"
EOF
```


In my opinion when possible *Terraform* should be used to provide infrastructure only and
deployment of the application itself should be handled separately.

[Don’t Deploy Applications with Terraform - Paul Durivage](https://medium.com/google-cloud/dont-deploy-applications-with-terraform-2f4508a45987)

## Set infrastructure



## Deployment

### App Engine

App Engine standard

```bash
export GAE_FILE=cloudbuild/gae_app_standard_deploy_cloudbuild.yaml
```

App Engine standard with Google Cloud Storage

```bash
export GAE_FILE=cloudbuild/gae_app_standard_with_gcs_deploy_cloudbuild.yaml
```

App Engine flexible (with Google Cloud Storage)

```bash
export GAE_FILE=cloudbuild/gae_app_flexible_cloudbuild.yaml
```

Deploy:

```bash
gcloud builds submit  \
    --project $PROJECT_ID \
    --config $GAE_FILE \
    --substitutions _INSTANCE_NAME=$SQL_DATABASE_INSTANCE_NAME,_REGION=$REGION,_SERVICE_NAME=$SERVICE_NAME
```

Display GAE application url:

```bash
gcloud app describe --format "value(defaultHostname)"
```

### Cloud Run

```bash
gcloud run deploy $SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --image gcr.io/$PROJECT_ID/polls-service \
    --set-cloudsql-instances $PROJECT_ID:$REGION:$SQL_DATABASE_INSTANCE_NAME \
    --allow-unauthenticated

gcloud run deploy $SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --image gcr.io/$PROJECT_ID/$SERVICE_NAME
```

## Warnings!

 1. Remember to edit `.gcloudignore`. It excludes all files except implicitly added.

## Links

https://cloud.google.com/python/django/appengine
https://cloud.google.com/python/django/flexible-environment
https://cloud.google.com/python/django/run
