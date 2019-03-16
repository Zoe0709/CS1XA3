from django.urls import path
from . import views

urlpatterns = [
    path('', views.randomname , name='helloapp-hello'),
]
