from django.conf.urls import include, url
from django.contrib import admin

from users.views import register, see_request, user_info, add_messages

urlpatterns = [
    url(r"^accounts/", include("django.contrib.auth.urls")),
    url(r"^register/", register, name="register"),
    url(r"^see_request/", see_request, name="see_request"),
    url(r"^user_info/", user_info, name="user_info"),
    url(r"^add_messages/", add_messages, name="add_messages"),
]
