from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

urlpatterns = [
	 path('e/ningh4/' , include('helloapp.urls')) ,
]
