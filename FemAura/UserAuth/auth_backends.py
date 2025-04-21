from django.contrib.auth.backends import BaseBackend
from .models import CustomUser
class EmailAuthBackend(BaseBackend):
    def authenticate(self, request, email=None, password=None, **kwargs):
        print("\n=== Authentication Attempt ===")
        print(f"Email received: {email}")
        
        try:
            user = CustomUser.objects.get(email=email)
            print(f"User found: {user.email}")
            
            if user.check_password(password):
                print("✓ Password valid")
                print(f"✓ User active: {user.is_active}")
                return user
            else:
                print("✗ Invalid password")
                return None
                
        except CustomUser.DoesNotExist:
            print("✗ User not found")
            return None

