from rest_framework.decorators import api_view
from drf_yasg.utils import swagger_auto_schema
from rest_framework.response import Response
from rest_framework import status
from drf_yasg import openapi
from django.core.mail import send_mail
from .models import CustomUser, OTP
from django.conf import settings
import random
from rest_framework import serializers
from .serializers import(validate_registration_data, 
                         create_user,
                         validate_otp_data,
                         validate_login_data)

from django.contrib.auth import authenticate, login

@swagger_auto_schema(
    method='post',
    operation_description="Register a new user. An OTP will be sent to the user's email for verification.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
            'password': openapi.Schema(type=openapi.TYPE_STRING, description='User password'),
            'confirmpassword': openapi.Schema(type=openapi.TYPE_STRING, description='Confirm password'),
            'last_period_date': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='Last period date'),
            'cycle_first_day': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='Cycle first day'),
            'cycle_length': openapi.Schema(type=openapi.TYPE_INTEGER, description='Cycle length in days'),
        },
        required=['email', 'password', 'confirmpassword'],
    ),
    responses={
        201: 'User registered successfully. OTP sent to email.',
        400: 'Invalid input data.',
    }
)

@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        try:
            # Validate registration data
            validated_data = validate_registration_data(request.data)
        except serializers.ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Create the user
        user = create_user(validated_data)

        # Generate a 4-digit OTP
        otp = random.randint(1000, 9999)

        # Save the OTP in the database
        OTP.objects.create(email=user.email, otp=otp)

        # Send the OTP to the user's email
        send_mail(
            'Your OTP for Email Verification',
            f'Your OTP is: {otp}',
            settings.EMAIL_HOST_USER,
            [user.email],
            fail_silently=False,
        )

        return Response({'message': 'OTP sent to your email. Please verify to complete registration.'}, status=status.HTTP_201_CREATED)
@swagger_auto_schema(
    method='post',
    operation_description="Verify the OTP sent to the user's email to activate the account.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
            'otp': openapi.Schema(type=openapi.TYPE_STRING, description='OTP sent to email'),
        },
        required=['email', 'otp'],
    ),
    responses={
        200: 'Email verified successfully. User account activated.',
        400: 'Invalid OTP or OTP expired.',
    }
)
@api_view(['POST'])
def verify_otp(request):
    if request.method == 'POST':
        try:
            # Validate OTP data
            validated_data = validate_otp_data(request.data)
        except serializers.ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Activate the user
        otp_record = validated_data['otp_record']
        user = CustomUser.objects.get(email=otp_record.email)
        user.is_active = True
        user.save()

        # Delete the OTP record 
        otp_record.delete()

        return Response({'message': 'Email verified successfully. You can now log in.'}, status=status.HTTP_200_OK)

@swagger_auto_schema(
    method='post',
    operation_description="Log in a user using their email and password.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
            'password': openapi.Schema(type=openapi.TYPE_STRING, description='User password'),
        },
        required=['email', 'password'],
    ),
    responses={
        200: 'Login successful.',
        400: 'Invalid email or password.',
    }
)
@api_view(['POST'])
def login_user(request):
    if request.method == 'POST':
        try:
            # Validate login data
            validated_data = validate_login_data(request.data)
        except serializers.ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Log the user in
        user = validated_data['user']
        login(request, user)
        return Response({'message': 'Login successful'}, status=status.HTTP_200_OK)
