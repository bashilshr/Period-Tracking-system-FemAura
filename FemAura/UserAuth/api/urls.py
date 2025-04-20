from django.urls import path
from UserAuth import views
from rest_framework_simplejwt.views import TokenRefreshView
urlpatterns = [
   path('register/', views.register_user, name='Register'),
   path('verify/', views.verify_otp, name='Verify'),
   path('login/', views.login_user, name='Login'),
   path('logout/',views.logout_user,name='Logout'),
   path('predict-cycle/', views.predict_cycle, name='predict_cycle'),
   path('get-period-history/', views.period_history, name='get_period_history'),
   path('log-cycle/', views.log_cycle, name='log_period'),
   path('export-data/', views.export_user_data, name='export-data'),
   path('request-password-reset/', views.request_password_reset, name='request_password_reset'),
    path('verify-otp_password/', views.verify_otp_password, name='verify_otp_password'),
    path('set-new-password/', views.set_new_password, name='set_new_password'),
    path('profile/', views.user_profile, name='user-profile'),
    path('profile/change-password/', views.change_password, name='change-password'),
    path('profile/delete/', views.delete_account, name='delete-account'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/protected/', views.protected_data, name='protected_data'),
]
