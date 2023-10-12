from django.shortcuts import render
from .models import Profile

# Create your views here.

def dashboard(request):
    return render(request, "base.html")

def profile_list(request):
    profiles = Profile.objects.exclude(user=request.user)
    return render(request, "dwitter/profile_list.html", {"profiles": profiles})

def profile(request, pk):
    profile = Profile.objects.get(pk=pk)
    return render(request, "dwitter/profile.html", {"profile": profile, "following_excluding_self": profile.follows.exclude(user=profile.user), "followers_excluding_self": profile.followed_by.exclude(user=profile.user)})