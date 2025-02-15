from django.contrib.auth.models import AbstractUser,BaseUserManager
from django.db import models
from django.utils import timezone
from datetime import timedelta

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')

        return self.create_user(email, password, **extra_fields)

class CustomUser(AbstractUser):
    objects = CustomUserManager() 
    email = models.EmailField(unique=True)
    last_period_date = models.DateField(null=True, blank=True)
    cycle_first_day = models.DateField(null=True, blank=True)
    cycle_length = models.IntegerField(null=True, blank=True)
    is_active = models.BooleanField(default=False)  # User is inactive until email is verified

    # Use email as the username field
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []  

    def __str__(self):
        return self.email
    

class OTP(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=4)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.email} - {self.otp}"

    def is_expired(self):
        return timezone.now() - self.created_at > timedelta(minutes=5)