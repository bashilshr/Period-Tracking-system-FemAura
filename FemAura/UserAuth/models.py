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
    date = models.DateField(null=True, blank= True)  # Date of the symptom occurrence
class Mood(models.Model):
    cycle = models.ForeignKey(Cycle, on_delete=models.CASCADE)  # Link to the cycle
    mood = models.CharField(max_length=100)  # Mood (e.g., happy, stressed)
    date = models.DateField(null= True, blank= True)  # Date of the mood occurrence
class PasswordResetOTP(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_verified = models.BooleanField(default=False)
    
    def is_expired(self):
        return timezone.now() - self.created_at > timedelta(minutes=15)

class ContentRecommendation(models.Model):
    
    PHASE_CHOICES = [
        ('menstrual', 'Menstrual Phase'),
        ('follicular', 'Follicular Phase'),
        ('ovulation', 'Ovulation Phase'),
        ('luteal', 'Luteal Phase'),
    ]
    
    mood = models.CharField(max_length=100, blank=True, null=True) 
    phase = models.CharField(max_length=20, choices=PHASE_CHOICES)
    symptom = models.CharField(max_length=100, blank=True, null=True)
    title = models.CharField(max_length=200)
    youtube_link = models.URLField()
    article_link = models.URLField(blank=True, null=True)
    description = models.TextField()
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.get_phase_display()} - {self.title}"
    
class DailyLog(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    date = models.DateField(default=timezone.now)
    experience = models.TextField(blank=True)
    cycle = models.ForeignKey('Cycle', null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        unique_together = ['user', 'date']
        ordering = ['-date']

    def __str__(self):
        return f"{self.user.email} - {self.date}"

class DailySymptom(models.Model):
    SYMPTOM_CHOICES = [
        ('NONE', 'Everything is good'),
        ('CRAMPS', 'Cramps'),
        ('FATIGUE', 'Fatigue'),
        ('HEADACHE', 'Headache'),
        ('INSOMNIA', 'Insomnia'),
        ('ACNE', 'Acne'),
        ('ABDOMINAL_PAIN', 'Abdominal Pain'),
        ('BREAST_TENDERNESS', 'Breast tenderness'),
        ('BACKPAIN', 'Backpain'),
        ('CRAVINGS', 'Cravings'),
    ]
    
    daily_log = models.ForeignKey(DailyLog, related_name='symptoms', on_delete=models.CASCADE)
    symptom = models.CharField(max_length=20, choices=SYMPTOM_CHOICES)

    class Meta:
        unique_together = ['daily_log', 'symptom']

    def __str__(self):
        return f"{self.daily_log.date}: {self.get_symptom_display()}"

class DailyMood(models.Model):
    MOOD_CHOICES = [
        ('CALM', 'Calm'),
        ('HAPPY', 'Happy'),
        ('LOW_ENERGY', 'Low energy'),
        ('IRRITATED', 'Irritated'),
        ('ANXIOUS', 'Anxious'),
        ('CRAVINGS', 'Cravings'),
        ('MOOD_SWINGS', 'Mood swings'),
        ('SAD', 'Sad'),
        ('ANGRY', 'Angry'),
        ('RELAXED', 'Relaxed'),
    ]
    
    daily_log = models.ForeignKey(DailyLog, related_name='moods', on_delete=models.CASCADE)
    mood = models.CharField(max_length=20, choices=MOOD_CHOICES)

    class Meta:
        unique_together = ['daily_log', 'mood']

    def __str__(self):
        return f"{self.daily_log.date}: {self.get_mood_display()}"