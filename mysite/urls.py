from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("", include("polls.urls")),
    path("admin/", admin.site.urls),
]

if not settings.GS_BUCKET_NAME:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
