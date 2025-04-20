from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, OTP
from django.utils import timezone
from datetime import timedelta
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
    validated_data.pop('confirmpassword')  # confirm password hatau
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
class ExportDataSerializer(serializers.Serializer):
    start_date = serializers.DateField(required=False)
    end_date = serializers.DateField(required=False)
    format = serializers.ChoiceField(
        choices=['csv', 'json', 'pdf'], 
        default='csv'
    )
    
class RequestPasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()

class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)

class NewPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField(max_length=6)
    new_password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords don't match")
        validate_password(data['new_password'])
        return data
#crud operation for user account
class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email', ]
        read_only_fields = ['email'] 

class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)
    confirm_password = serializers.CharField(required=True)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError("New passwords don't match")
        validate_password(data['new_password'])
        return data

