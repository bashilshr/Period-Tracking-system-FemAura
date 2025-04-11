from django.urls import path
from UserAuth import views

urlpatterns = [
   path('register/', views.register_user, name='Register'),
   path('verify/', views.verify_otp, name='Verify'),
   path('login/', views.login_user, name='Login'),
   path('logout/',views.logout_user,name='Logout'),
   path('predict-cycle/', views.predict_cycle, name='predict_cycle'),
   path('get-period-history/', views.period_history, name='get_period_history'),
   path('log-cycle/', views.log_cycle, name='log_period'),
   path('resend-otp/', views.resend_otp, name='resend_otp'),
]
