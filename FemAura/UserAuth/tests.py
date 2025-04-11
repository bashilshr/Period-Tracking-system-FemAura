# tests.py
from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import CustomUser

class PasswordTests(TestCase):
    def test_password_hashing(self):
        # Get the custom user model
        User = get_user_model()
        
        # Create and test a new user
        email = "testuser@example.com"
        password = "TestPass123"
        
        user = User.objects.create_user(
            email=email,
            password=password,
            is_active=True
        )
        
        # Verify password check works
        self.assertTrue(user.check_password(password))
        self.assertFalse(user.check_password("wrongpassword"))
        
        print(f"Password test passed for {email}")