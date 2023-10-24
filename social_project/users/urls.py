from django.conf.urls import include, url
from django.contrib import admin

app_name = "users"
from users.views import register

urlpatterns = [
    url(r"^accounts/", include("django.contrib.auth.urls")),
    url(r"^register/", register, name="register"),
]
