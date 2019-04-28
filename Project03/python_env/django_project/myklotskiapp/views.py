from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from . models import UserInfo

# Create your views here.
def signupUser(request):
	json_req = json.loads(request.body)
	username = json_req.get('username','')
	password = json_req.get('password','')
	if username != '' and password != '':
		user = User.objects.create_user(username=username, password=password)
		userinfo = UserInfo.objects.create(user=user)
		return HttpResponse('Success')
	else:
		return HttpResponse('Fail')

def loginUser(request):
	print(str(request))
	json_req = json.loads(request.body.decode('utf-8'))
	username = json_req.get('username','')
	password = json_req.get('password','')
	user = authenticate(request,username=username,password=password)
	if user is not None:
		login(request,user)
		return HttpResponse('Success')
	else:
		return HttpResponse('Fail')

def logoutUser(request):
	logout(request)
	return HttpResponse('Success')

def highscore(request):
	json_req = json.loads(request.body.decode('utf-8'))
	highscore = json_req.get('highscore',0)
	user = request.user
	if user.is_authenticated:
		userinfo = UserInfo.objects.get(user=user)
		if highscore < userinfo.highscore:
			userinfo.highscore = highscore
			userinfo.save()
		return HttpResponse('Success')
	else:
		return HttpResponse('Fail')

def userscoreget(request):
        user = request.user
        if user.is_authenticated:
                userinfo = UserInfo.objects.get(user=user)
                highscore = userinfo.highscore
                d = {}
                d['username'] = user.username
                d['highscore'] = userinfo.highscore
                return JsonResponse(d)
        else:
                return HttpResponse('Fail')
