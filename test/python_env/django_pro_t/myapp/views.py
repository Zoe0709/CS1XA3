from django.shortcuts import render

from django.http import JsonResponse
from .models import Person

def models_view(request):
   query_set = Person.objects.all()
   # ... do something with query_set
   return JsonResponse(...)

# Create your views here.
