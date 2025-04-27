# tests/test_models/test_user.py
import pytest
from django.core.exceptions import ValidationError
from  UserAuth.models import CustomUser

@pytest.mark.django_db
class TestCustomUserModel:
    def test_create_user(self):
        user = CustomUser.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        assert user.email == 'test@example.com'
        assert user.check_password('testpass123')
        assert not user.is_superuser

    def test_email_normalization(self):
        user = CustomUser.objects.create_user(
            email='Test@Example.COM',
            password='test123'
        )
        assert user.email == 'Test@example.com'

    def test_blank_email(self):
        with pytest.raises(ValueError):
            CustomUser.objects.create_user(email='', password='test123')