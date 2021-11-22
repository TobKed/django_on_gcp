
# How to deploy Django application on Google Cloud Platform.


## Introduction

Cloud is consistently growing and it may be worth to consider it for your next Python project.
But Cloud is also complex, number of available services is still growing, so decisions so if you want create configuration for your project.
If you want learn how to run simple Django app in the Google Cloud Platform [GCP], how easy it can be done and also get the underlying services in form of the code (Infrastructure as Code [IaC])here it is the place for you.

THere are many ways to deploy an Django application on the GCP:

 - App Engine:
 - Cloud Run (with GCS storage) (blog post)
 - Kubernetes (maybe covered here, we will see) (blog post)
 - Compute Engine

Most of them are covered in [GCP documentation](https://cloud.google.com/python/django/) which is quite good im my opinion, however if you are not familiar with the cloud all these services and operations may seem confusing (and reduntant).
Django apps in mentioned tutorials are almost the same, they have changes dependent on the service type on which they were supossed to be running of course, however some changes are not related.
Moreover, I found some of these tutorials and app may contain some tiny bugs.

So what I have done here is an simple Django application where all changes which are specific to given GCP services are grouped and could be found in the possible least number of places for ease of analysis.
Additionaly infrastructure is wrapped in the Terraform (IaC tool) which allows you easily create (and destroy) all necessary resources.
Process of deploying application itself is not handled by Terraform ([Don’t Deploy Applications with Terraform - Paul Durivage](https://medium.com/google-cloud/dont-deploy-applications-with-terraform-2f4508a45987)) but it is wrapped in the Google Cloud Build [GCB] pipelines,
separate for each service and easy to follow. Inheritance between GCB pipelines is not possible, hence they have a lot of in common but diff analysis between them should not be a problem for you.
For GCB purpose I wraped up app in Docker, even App Engine does not require it, but it was the easiest way to provide proxy connections to Cloud SQL.

Hopefully such condensed project may help you to learn how interconnected Cloud services may be used along with Python project so some ideas could be picked in the future.


## Perequisites

Topics with which you should be familiar with since they will be not covered:

 - Python and Django
 - Cloud - basic cloud conecpts in general
 - Google Cloud Platform: basics of the services, usage of `gcloud` CLI, managing billing, documentation about [Django on GCP](GCP documentation](https://cloud.google.com/python/django/)
 - Terraform - basics of usage, see my tutorial on Medium: [Terraform Tutorial: Introduction to Infrastructure as Code](https://tobiaszkedzierski.medium.com/terraform-tutorial-introduction-to-infrastructure-as-code-dccec643bfdb)

What you should  prepare:
 - Google Cloud Project - create fresh GCP project or use existing (however it may cause Terraform exceptions)
 - [`gcloud`](https://cloud.google.com/sdk/gcloud) - install GCP cli and authorize it with proper GCP Projectd
 - [Terraform](https://www.terraform.io/downloads.html) - install latest version
 - Python [optionally] - Python 3.9 in virtual environment if you want to run Django app locally


-- no do review below this line
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

### App Engine

App Engine standard

```bash
export CLOUD_BUILD_FILE=cloudbuild/gae_app_standard_deploy.yaml
```

App Engine standard with Google Cloud Storage

```bash
export CLOUD_BUILD_FILE=cloudbuild/gae_app_standard_with_gcs_deploy.yaml
```

App Engine flexible (with Google Cloud Storage)

```bash
export CLOUD_BUILD_FILE=cloudbuild/gae_app_flexible.yaml
```

Deploy:

```bash
gcloud builds submit  \
    --project $PROJECT_ID \
    --config $CLOUD_BUILD_FILE \
    --substitutions _INSTANCE_NAME=$SQL_DATABASE_INSTANCE_NAME,_REGION=$REGION,_SERVICE_NAME=$SERVICE_NAME
```

Display GAE application url:

```bash
gcloud app describe --format "value(defaultHostname)"
```

### Cloud Run

```bash
export CLOUD_BUILD_FILE=cloudbuild/cloud_run.yaml
```

```bash
gcloud builds submit  \
    --project $PROJECT_ID \
    --config $CLOUD_BUILD_FILE \
    --substitutions _INSTANCE_NAME=$SQL_DATABASE_INSTANCE_NAME,_REGION=$REGION,_SERVICE_NAME=$SERVICE_NAME,_SERVICE_ACCOUNT_NAME=$SERVICE_ACCOUNT_NAME
```

### GKE

```bash
export CLOUD_BUILD_FILE=cloudbuild/gke.yaml
```

## Warnings!

 1. Remember to edit `.gcloudignore`. It excludes all files except implicitly added.

## Links

 - https://cloud.google.com/python/django/appengine
 - https://cloud.google.com/python/django/flexible-environment
 - https://cloud.google.com/python/django/run

## TODO

 - autogenerate cloud run service account based on the service name, less envs, simpler !
 -
