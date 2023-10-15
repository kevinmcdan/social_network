from django.conf.urls import include, url
from django.contrib import admin

app_name = "users"

urlpatterns = [
    url(r"^accounts/", include("django.contrib.auth.urls")),
]