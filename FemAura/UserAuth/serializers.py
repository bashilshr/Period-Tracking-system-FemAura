from wsgiref.validate import validator
from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import CustomUser, OTP, DailyLog, DailySymptom, DailyMood, Cycle
from django.utils import timezone
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.core import validators
from django.core.validators import validate_email, RegexValidator

# Function to validate registration data
def validate_registration_data(data):
    errors = {}
    
    if 'password' not in data:
        errors['password'] = ['This field is required.']
    if 'confirmpassword' not in data:
        errors['confirmpassword'] = ['This field is required.']
    
    if errors:
        raise serializers.ValidationError(errors)
    
    if data['password'] != data['confirmpassword']:
        raise serializers.ValidationError({
            'confirmpassword': ['Password and Confirm Password do not match.']
        })
    
    try:
        validate_password(data['password'])
    except ValidationError as e:
        raise serializers.ValidationError({
            'password': e.messages
        })
    
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
# serializers.py
class ExportDataSerializer(serializers.Serializer):
    start_date = serializers.DateField(required=False)
    end_date = serializers.DateField(required=False)
    format = serializers.ChoiceField(
        choices=['csv', 'json', 'pdf'], 
        default='csv'
    )

    def validate(self, data):
        if data.get('end_date') and not data.get('start_date'):
            raise serializers.ValidationError({
            'start_date': 'start_date must be provided when using end_date'
        })
        # Validate date range if both are provided
        if data.get('start_date') and data.get('end_date'):
            if data['start_date'] > data['end_date']:
                raise serializers.ValidationError({
                    'end_date': 'Must be after start_date'
                })
        
        return data
    
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
    email = serializers.EmailField(required=False)
    username = serializers.CharField(
        max_length=150,
        validators=[
            RegexValidator(
                r'^[\w.@+-]+$',
                message='Enter a valid username.'
            ),
            validators.MaxLengthValidator(150)  # Explicit length validator
        ]
    )

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'email']
        extra_kwargs = {
            'username': {
                'required': True,
                'max_length': 150  # Meta-level validation
            }
        }
    def validate_email(self, value):
        if value:
            try:
                validate_email(value)
            except validators.ValidationError:
                raise serializers.ValidationError("Enter a valid email address")
        return value

    def validate_username(self, value):
        """Custom username validation with explicit length check"""
        if len(value) > 16:
            raise serializers.ValidationError(
                "Ensure this field has no more than 16 characters"
            )
        return value
    
class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)
    confirm_password = serializers.CharField(required=True)

    def validate(self, data):
        # Check password match
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({
                'non_field_errors': ["Passwords don't match"]
            })

        # Check new password is different
        if data['new_password'] == data['old_password']:
            raise serializers.ValidationError({
                'non_field_errors': ["New password must be different"]
            })

        # Validate password strength
        try:
            validate_password(data['new_password'])
        except ValidationError as e:
            raise serializers.ValidationError({
                'new_password': list(e.messages)
            })

        return data

class DailySymptomSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailySymptom
        fields = ['id', 'symptom']
        extra_kwargs = {
            'symptom': {'required': True}
        }

    def validate_symptom(self, value):
        valid_choices = [choice[0] for choice in DailySymptom.SYMPTOM_CHOICES]
        if value not in valid_choices:
            raise serializers.ValidationError("Invalid symptom selection")
        return value

class DailyMoodSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyMood
        fields = ['id', 'mood']
        extra_kwargs = {
            'mood': {'required': True}
        }

    def validate_mood(self, value):
        if value not in dict(DailyMood.MOOD_CHOICES):
            raise serializers.ValidationError("Invalid mood selection")
        return value

class DailyLogSerializer(serializers.ModelSerializer):
    experience = serializers.CharField(
        max_length=500,
        validators=[
            validators.ProhibitNullCharactersValidator(),
            validators.validate_slug  # Basic XSS protection
        ]
    )
    class Meta:
        model = DailyLog
        fields = ['id', 'date', 'experience', 'symptoms', 'moods']
        extra_kwargs = {
            'date': {'required': False},
            'experience': {'required': False}
        }

    def validate_experience(self, value):
        if len(value) > 500:
            raise serializers.ValidationError("Experience cannot exceed 500 characters")
        if '<script>' in value.lower():
            raise serializers.ValidationError("Invalid input detected")
        return value

    def create(self, validated_data):
        symptoms_data = validated_data.pop('symptoms', [])
        moods_data = validated_data.pop('moods', [])
        
        log, created = DailyLog.objects.update_or_create(
            user=validated_data['user'],
            date=validated_data.get('date', timezone.now().date()),
            defaults=validated_data
        )
        
        # Handle symptoms
        DailySymptom.objects.filter(daily_log=log).delete()
        for symptom_data in symptoms_data:
            DailySymptom.objects.create(daily_log=log, **symptom_data)
        
        # Handle moods
        DailyMood.objects.filter(daily_log=log).delete()
        for mood_data in moods_data:
            DailyMood.objects.create(daily_log=log, **mood_data)
        
        # Link to cycle
        self._link_to_cycle(log)
        return log

    def _link_to_cycle(self, log):
        if not log.cycle:
            cycle = Cycle.objects.filter(
                user=log.user,
                start_date__lte=log.date,
                end_date__gte=log.date
            ).first()
            if cycle:
                log.cycle = cycle
                log.save()