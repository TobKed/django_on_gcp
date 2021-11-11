
# How to deploy Django application on Google Cloud Platform.



There are many ways to deploy Django application on GCP:

 - App Engine:
   - standard environment
   - flexible environment
 - Cloud Run
 - Kubernetes (maybe covered here, we will see)
 - Compute Engine (not covered here)



## App Engine - standard environment


INSTANCE_NAME=db-instance-2116a9ba
REGION=europe-west3

gcloud builds submit \
    --config cloudbuild/gae_app_standard_deploy_cloudbuild.yaml \
    --substitutions _INSTANCE_NAME=$INSTANCE_NAME,_REGION=$REGION

## Warnings!

 1. Remember to edit `.gcloudignore`. It excludes all files except implicitly added.
