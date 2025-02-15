from django.urls import path
from UserAuth import views

urlpatterns = [
   path('register/', views.register_user, name='Register'),
   path('verify/', views.verify_otp, name='Verify'),
   path('login/', views.login_user, name='Login'),
]
