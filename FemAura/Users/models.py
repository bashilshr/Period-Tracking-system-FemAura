from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class UserSignUp(models.Model):
    firstname = models.CharField(max_length=50)
    lastname = models.CharField(max_length=50)
    email = models.EmailField()
    password = models.CharField(max_length=50)
    def __str__(self):
        return self.firstname