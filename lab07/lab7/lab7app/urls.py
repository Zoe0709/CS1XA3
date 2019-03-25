from django.urls import path
from . import views

urlpatterns = [
    path('', views.some_Post , name='lab7app'),
]
