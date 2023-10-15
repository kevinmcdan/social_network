from django.shortcuts import render, redirect
from .forms import DweetForm
from .models import Dweet, Profile
from operator import attrgetter

# Create your views here.

def dashboard(request):
    if request.user.is_authenticated:
        form = DweetForm(request.POST or None)
        if request.method == "POST":
            if form.is_valid():
                dweet = form.save(commit=False)
                dweet.user = request.user
                dweet.save()
                return redirect("dwitter:dashboard")
        followed_dweets = Dweet.objects.filter(user__profile__in=request.user.profile.follows.all()).order_by("-created_at")
        # print(followed_dweets.query) # uncomment when debugging
        return render(request, "dwitter/dashboard.html", {"form": form, "dweets": followed_dweets},)
    else:
        return redirect("users:login")

def profile_list(request):
    profiles = Profile.objects.exclude(user=request.user)
    return render(request, "dwitter/profile_list.html", {"profiles": profiles})

def profile(request, pk):
    if not hasattr(request.user, 'profile'):
        missing_profile = Profile(user=request.user)
        missing_profile.save()

    profile = Profile.objects.get(pk=pk)
    if request.method == "POST":
        current_user_profile = request.user.profile
        data = request.POST
        action = data.get("follow")
        if action == "follow":
            current_user_profile.follows.add(profile)
        elif action == "unfollow":
            current_user_profile.follows.remove(profile)
        current_user_profile.save()
    return render(request, "dwitter/profile.html", {"profile": profile, "following_excluding_self": profile.follows.exclude(user=profile.user), "followers_excluding_self": profile.followed_by.exclude(user=profile.user)})