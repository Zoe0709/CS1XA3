from django.shortcuts import render
from django.http import HttpResponse

def randomname(request):
     html = "<html><body>Hello World</body></html>"
     return HttpResponse(html)
