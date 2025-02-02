from django.db import models
from secrets import token_urlsafe
class UserModel(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)  
    is_active = models.BooleanField(default=False) 
    email_verification_token = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.email

def generate_token():
    return token_urlsafe(32)
