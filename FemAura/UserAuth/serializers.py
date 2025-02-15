from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, OTP
from django.utils import timezone
from datetime import timedelta

# Function to validate registration data
def validate_registration_data(data):
    if data['password'] != data['confirmpassword']:
        raise serializers.ValidationError("Password and Confirm Password do not match.")
    return data

# Function to create a user
def create_user(data):
    validated_data = data.copy()
    validated_data.pop('confirmpassword')  # Remove confirmpassword before creating the user
    user = CustomUser.objects.create_user(**validated_data)
    return user

# Function to validate login data
def validate_login_data(data):
    email = data.get('email')
    password = data.get('password')

    if email and password:
        user = authenticate(email=email, password=password)
        if user:
            if not user.is_active:
                raise serializers.ValidationError("User account is not active.")
            data['user'] = user
        else:
            raise serializers.ValidationError("Unable to log in with provided credentials.")
    else:
        raise serializers.ValidationError("Must include 'email' and 'password'.")
    return data

# Function to validate OTP data
def validate_otp_data(data):
    email = data.get('email')
    otp = data.get('otp')

    try:
        otp_record = OTP.objects.filter(email=email).latest('created_at')
    except OTP.DoesNotExist:
        raise serializers.ValidationError("OTP not found or expired.")

    if timezone.now() - otp_record.created_at > timedelta(minutes=5):
        raise serializers.ValidationError("OTP expired.")

    if otp_record.otp != otp:
        raise serializers.ValidationError("Invalid OTP.")

    data['otp_record'] = otp_record
    return data