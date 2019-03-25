from django.shortcuts import render
from django.http import HttpResponse


def some_Post(request):
	username = request.POST.get("name","")
	password = request.POST.get("password","")
	if username == "Jimmy" and password == "Hendrix":
		return HttpResponse("Cool")
	else:
		return HttpResponse("Bad User Name")
