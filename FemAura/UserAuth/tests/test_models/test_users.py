import pytest
from django.core.exceptions import ValidationError
from UserAuth.models import CustomUser, OTP

@pytest.mark.django_db
class TestCustomUserModel:
    def test_user_creation(self):
        user = CustomUser.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        assert user.email == 'test@example.com'
        assert user.check_password('testpass123')
        assert not user.is_superuser
        assert not user.is_staff

    def test_superuser_creation(self):
        admin = CustomUser.objects.create_superuser(
            email='admin@example.com',
            password='adminpass123'
        )
        assert admin.is_superuser
        assert admin.is_staff

    def test_email_normalization(self):
        user = CustomUser.objects.create_user(
            email='Test@Example.COM',
            password='test123'
        )
        assert user.email == 'Test@example.com'

    def test_blank_email(self):
        with pytest.raises(ValueError):
            CustomUser.objects.create_user(email='', password='test123')

    def test_duplicate_email(self):
        CustomUser.objects.create_user(email='dupe@example.com', password='test123')
        with pytest.raises(ValidationError):
            user = CustomUser(email='dupe@example.com', password='test123')
            user.full_clean()
