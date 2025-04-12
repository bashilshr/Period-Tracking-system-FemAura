from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, OTP
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

# Function to validate registration data
def validate_registration_data(data):
    if data['password'] != data['confirmpassword']:
        raise serializers.ValidationError("Password and Confirm Password do not match.")
    
    try:
        validate_password(data['password'])
    except ValidationError as e:
        raise serializers.ValidationError(e.messages)
    
    return data
# Function to create a user
def create_user(data):
    validated_data = data.copy()
    validated_data.pop('confirmpassword', None)
    
    email = validated_data.get('email', '').lower().strip()
    validated_data['email'] = email
    
    if CustomUser.objects.filter(email__iexact=email).exists():
        raise serializers.ValidationError("An account with this email already exists.")
    
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

    if otp_record.is_expired():
        raise serializers.ValidationError("OTP expired.")

    if otp_record.otp != otp:
        raise serializers.ValidationError("Invalid OTP.")

    data['otp_record'] = otp_record
    return data

