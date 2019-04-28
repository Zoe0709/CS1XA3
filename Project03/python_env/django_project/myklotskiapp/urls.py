from django.urls import path
from . import views

urlpatterns = [
	path('signup/', views.signupUser, name='myklotskiapp-sigupUser'),
	path('login/', views.loginUser, name='myklotskiapp-loginUser'),
	path('logout/', views.logoutUser, name='myklotskiapp-logoutUser'), 
	path('highscore/', views.highscore, name='myklotskiapp-highscore'),
	path('userscoreget/', views.userscoreget, name='myklotskiapp-userscoreget'),
]
