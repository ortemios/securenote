from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    phone = models.DecimalField(max_digits=10, decimal_places=0, primary_key=True)


class Note(models.Model):
    user = models.ForeignKey(to=User, on_delete=models.CASCADE, null=True)
    title = models.TextField()
    content = models.TextField()


class SmsCode(models.Model):
    phone = models.DecimalField(max_digits=10, decimal_places=0, primary_key=True)
    pin = models.CharField(max_length=6)
    updated_at = models.DateTimeField(auto_now=True)
