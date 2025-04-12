from django.contrib.auth.models import AbstractUser,BaseUserManager
from django.utils import timezone
from datetime import timedelta
from django.db import models
from django.conf import settings

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
    is_active = models.BooleanField(default=False)  # User is inactive until email is verified

    # Use email as the username field
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []  

    def __str__(self):
        return self.email
    

class OTP(models.Model):
    username = models.CharField(max_length=255)
    email = models.EmailField()
    otp = models.CharField(max_length=6)  # Changed to 6 digits
    created_at = models.DateTimeField(auto_now_add=True)
    attempts = models.PositiveIntegerField(default=1)  # Add this field
    
    def __str__(self):
        return f"{self.email} - {self.otp}"

    def is_expired(self):
        return timezone.now() - self.created_at > timedelta(minutes=10)  # Changed to 10 minutes
#============= For Cycle prediction =============


class Cycle(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)  # Link to the user
    start_date = models.DateField()  # Start date of the period
    end_date = models.DateField()  # End date of the period
    cycle_length = models.IntegerField(blank=True, null=True)  # Calculated cycle length

    def save(self, *args, **kwargs):
        # Calculate cycle length automatically
        if self.start_date and self.end_date:
            self.cycle_length = (self.end_date - self.start_date).days
        super().save(*args, **kwargs)

class Symptom(models.Model):
    cycle = models.ForeignKey(Cycle, on_delete=models.CASCADE)  # Link to the cycle
    symptom = models.CharField(max_length=100)  # Symptom name (e.g., cramps)
    intensity = models.IntegerField()  # Intensity of the symptom (1-10)

class Mood(models.Model):
    cycle = models.ForeignKey(Cycle, on_delete=models.CASCADE)  # Link to the cycle
    mood = models.CharField(max_length=100)  # Mood (e.g., happy, stressed)