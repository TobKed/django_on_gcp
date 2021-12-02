<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [How to deploy Django application on Google Cloud Platform.](#how-to-deploy-django-application-on-google-cloud-platform)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Instructions](#instructions)
    - [1. Variables specific for your GCP project](#1-variables-specific-for-your-gcp-project)
    - [2. Set up infrastructure](#2-set-up-infrastructure)
    - [3. Deploy app](#3-deploy-app)
  - [Warnings!](#warnings)
  - [Links](#links)
  - [TODO](#todo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


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


## Prerequisites

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


## Instructions

### 1. Variables specific for your GCP project

1. Shell environmental variables

Set environmental variables.
Some values you have to know by hard, like `PROJECT_ID`.
Other you can generate on fly, like `DJANGO_SECRET_KEY` however remember to keep them somewhere (see next step).
They will be used to provide input variables for terraform and for `gcloud` commands.

```bash
export PROJECT_ID=django-cloud-tf-test-001
export REGION=europe-central2
export ZONE=europe-central2-a
export SQL_DATABASE_INSTANCE_NAME="${PROJECT_ID}-db-instance"
export SQL_DATABASE_NAME="${PROJECT_ID}-db"
export SERVICE_NAME=polls-service
export SERVICE_ACCOUNT_NAME=polls-service-account  # for cloud run
export SERVICE_ACCOUNT="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"   # for cloud run

export DJANGO_SECRET_KEY=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 50 | head -n1)
export SQL_USER=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 10 | head -n1)
export SQL_PASSWORD=$(cat /dev/urandom | LC_ALL=C tr -dc '[:alpha:]'| fold -w 10 | head -n1)
```

1. `gcloud` config project

```bash
gcloud config set project $PROJECT_ID
```

2. Terraform variables

Terraform can read variables from environment variables.
Naming convention is `TF_VAR_variable_name`.

```bash
export TF_VAR_project_id=$PROJECT_ID
export TF_VAR_region=$REGION
export TF_VAR_zone=$ZONE
export TF_VAR_django_secret_key=$DJANGO_SECRET_KEY
export TF_VAR_sql_database_instance_name=$SQL_DATABASE_INSTANCE_NAME
export TF_VAR_sql_database_name=$SQL_DATABASE_NAME
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
sql_database_name              = "$SQL_DATABASE_NAME"
sql_user                       = "$SQL_USER"
sql_password                   = "$SQL_PASSWORD"
cloud_run_service_account_name = "$SERVICE_ACCOUNT_NAME"
EOF
```

### 2. Set up infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Known issues:

 - 13 years old google issue [No way to delete an application ](https://issuetracker.google.com/issues/35874988)

    ```Error: Error creating App Engine application: googleapi: Error 409: This application already exists and cannot be re-created., alreadyExist```

 - random null for `data.google_project.project.number`, https://github.com/hashicorp/terraform-provider-google/issues/10587#issuecomment-984589651:

    ```The expression result is null. Cannot include a null value in a string template.```

### 3. Deploy app

In my opinion when possible *Terraform* should be used to provide infrastructure only and
deployment of the application itself should be handled separately.

[Don’t Deploy Applications with Terraform - Paul Durivage](https://medium.com/google-cloud/dont-deploy-applications-with-terraform-2f4508a45987)

1. Set GCB pipeline

 - App Engine standard environment

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/gae_app_standard_deploy.yaml
    ```

 - App Engine standard environment with Google Cloud Storage

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/gae_app_standard_with_gcs_deploy.yaml
    ```

 - App Engine flexible environment (with Google Cloud Storage)

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/gae_app_flexible.yaml
    ```

 - Cloud Run

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/cloud_run.yaml
    ```

 - Kubernetes

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/gke.yaml
    ```

2. Deploy

    Path in `CLOUD_BUILD_FILE` is intended bo being run from root repository directory.

 - App Engine

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

    Known issues:

   - error during last step, terraform google provider issue, wait a little and retry

     `Step #5 - "deploy app": ERROR: (gcloud.app.deploy) NOT_FOUND: Unable to retrieve P4SA: [service-123456789101@gcp-gae-service.iam.gserviceaccount.com] from GAIA. Could be GAIA propagation delay or request from deleted apps.
Finished Step #5 - "deploy app"`


 - Cloud Run

    ```bash
    export CLOUD_BUILD_FILE=cloudbuild/cloud_run.yaml
    ```

    ```bash
    gcloud builds submit  \
        --project $PROJECT_ID \
        --config $CLOUD_BUILD_FILE \
        --substitutions _INSTANCE_NAME=$SQL_DATABASE_INSTANCE_NAME,_REGION=$REGION,_SERVICE_NAME=$SERVICE_NAME,_SERVICE_ACCOUNT_NAME=$SERVICE_ACCOUNT_NAME
    ```

    Display Cloud Run application url:

    ```bash
    gcloud run services list --filter SERVICE:$SERVICE_NAME --format "value(status.address.url)"
    ```

3. Destroy infrastructure

```shell
terraform destroy
```


## Warnings!

 1. Remember to edit `.gcloudignore`. It excludes all files except implicitly added.

## Links

 - https://cloud.google.com/python/django/appengine
 - https://cloud.google.com/python/django/flexible-environment
 - https://cloud.google.com/python/django/run

## TODO

 - [ ] migration with superadmin creation
 - [ ] autogenerate cloud run service account based on the service name, fewer envs, simpler !
