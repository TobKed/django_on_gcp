import io
import os

import environ
from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from google.cloud import secretmanager

env = environ.Env()


class Command(BaseCommand):
    help = "Create superuser with credentials from secrets"

    def handle(self, *args, **options):
        project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
        superuser_credentials = os.environ.get(
            "SUPERUSER_CREDENTIALS", "superuser_credentials"
        )
        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{project_id}/secrets/{superuser_credentials}/versions/latest"
        payload = client.access_secret_version(name=name).payload.data.decode("UTF-8")
        env.read_env(io.StringIO(payload))

        username = env.str("USERNAME")
        password = env.str("PASSWORD")

        User.objects.create_superuser(
            username=username.strip(), password=password.strip()
        )

        self.stdout.write(self.style.SUCCESS("Successfully created superuser"))
