from venv import logger
from rest_framework.decorators import api_view,permission_classes
from django.views.decorators.csrf import csrf_exempt
from drf_yasg.utils import swagger_auto_schema
from rest_framework.response import Response
from .models import CustomUser, OTP, Cycle
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from drf_yasg import openapi
from django.core.mail import send_mail
from django.conf import settings
import random
from rest_framework import serializers
from .serializers import(validate_registration_data, 
                         create_user,
                         validate_otp_data,
                         validate_login_data)
from .utils import (get_average_cycle_length,get_current_day,
                    get_ovulation_status,get_period_history,
                    get_phase)
from django.contrib.auth import authenticate, login, logout


from datetime import datetime, timedelta
from django.utils import timezone

#for registering a user
@swagger_auto_schema(
    method='post',
    operation_description="Register a new user. An OTP will be sent to the user's email for verification.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'username': openapi.Schema(type=openapi.TYPE_STRING, description='User name'),
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
        400: 'Invalid input data or email already exists.',
    }
)
@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        try:
            validated_data = validate_registration_data(request.data)
            email = validated_data['email'].lower().strip()
            
            existing_user = CustomUser.objects.filter(email__iexact=email).first()
            
            if existing_user:
                if existing_user.is_active:
                    return Response(
                        {'error': 'Email already registered.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                user = existing_user  # Resend OTP for inactive user
            else:
                user = create_user(validated_data)

            otp = str(random.randint(100000, 999999))  # 6-digit OTP
            OTP.objects.filter(email=user.email).delete()  # Clear old OTPs
            OTP.objects.create(email=user.email, otp=otp)
            
            send_mail(
                'Your OTP Code',
                f'Your verification code: {otp} (valid for 10 mins)',
                settings.EMAIL_HOST_USER,
                [user.email],
                fail_silently=False,
            )
            return Response(
                {'message': 'OTP sent. Check your email.'},
                status=status.HTTP_201_CREATED
            )
        except serializers.ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
#==========================verify otp======================= 
            
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
    operation_description="Resend OTP to the user's email",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(type=openapi.TYPE_STRING, description='User email'),
        },
        required=['email'],
    ),
    responses={
        200: 'OTP resent successfully',
        400: 'Invalid email or no account found',
        403: 'Account already activated',
        429: 'Too many OTP requests',
    }
)
@api_view(['POST'])
def resend_otp(request):
    email = request.data.get('email', '').lower().strip()
    
    try:
        user = CustomUser.objects.get(email=email)
        if user.is_active:
            return Response(
                {'error': 'Account already active.'},
                status=status.HTTP_403_FORBIDDEN
            )
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'Email not registered.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Rate limiting (3 OTPs/hour max)
    last_hour = timezone.now() - timedelta(hours=1)
    recent_otps = OTP.objects.filter(email=email, created_at__gte=last_hour).count()
    if recent_otps >= 3:
        return Response(
            {'error': 'Too many attempts. Try later.'},
            status=status.HTTP_429_TOO_MANY_REQUESTS
        )

    otp = str(random.randint(100000, 999999))
    OTP.objects.filter(email=email).delete()
    OTP.objects.create(email=email, otp=otp)

    send_mail(
        'Your New OTP',
        f'New OTP: {otp}',
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False,
    )
    return Response(
        {'message': 'OTP resent.'},
        status=status.HTTP_200_OK
    )

@api_view(['POST'])
def login_user(request):
    email = request.data.get('email', '').lower().strip()
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Email and password required.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = CustomUser.objects.get(email=email)
    except CustomUser.DoesNotExist:
        return Response(
            {'error': 'User not found.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if not user.is_active:
        return Response(
            {'error': 'Verify your email first.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    if not user.check_password(password):
        return Response(
            {'error': 'Incorrect password.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    login(request, user)
    return Response(
        {'message': 'Login successful.'},
        status=status.HTTP_200_OK
    )

@swagger_auto_schema(
    method='post',
    operation_description="Log out the authenticated user.",
    responses={
        200: 'Logout successful.',
        401: 'User not authenticated.',
    }
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout_user(request):
    """
    Log out the authenticated user.
    """
    try:
        logout(request)
        return Response({'message': 'Logout successful'}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
#==========================prediction of cycle=======================
#swagger for period tracking from users input
@swagger_auto_schema(
    method='post',
    operation_description="Log a new menstrual cycle for the authenticated user.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'start_date': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='Start date of the period'),
            'end_date': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='End date of the period'),
        },
        required=['start_date', 'end_date'],
    ),
    responses={
        201: openapi.Response('Cycle logged successfully'),
        400: openapi.Response('Invalid input data'),
    }
)
@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def log_cycle(request):
    """
    Log a new menstrual cycle for the authenticated user.
    """
    try:
        user = request.user
        start_date_str = request.data.get('start_date')
        end_date_str = request.data.get('end_date')

        # Validate input data
        if not start_date_str or not end_date_str:
            return Response({'error': 'Both start_date and end_date are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Parse the input strings into date objects
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response({'error': 'Invalid date format. Use YYYY-MM-DD'}, status=status.HTTP_400_BAD_REQUEST)

        # Ensure end_date is after start_date
        if end_date <= start_date:
            return Response({'error': 'end_date must be after start_date'}, status=status.HTTP_400_BAD_REQUEST)

        # Create and save the Cycle instance
        cycle = Cycle(user=user, start_date=start_date, end_date=end_date)
        cycle.save()

        return Response({'message': 'Cycle logged successfully'}, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
#swagger for prediction of cycle
@swagger_auto_schema(
    method='get',
    operation_description="Predict cycle-related information for the authenticated user.",
    responses={
        200: openapi.Response(
            description="Cycle information predicted successfully",
            schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'avg_cycle_length': openapi.Schema(type=openapi.TYPE_INTEGER, description='Average cycle length'),
                    'current_day': openapi.Schema(type=openapi.TYPE_INTEGER, description='Current day of the cycle'),
                    'ovulation_status': openapi.Schema(type=openapi.TYPE_STRING, description='Ovulation status'),
                    'phase': openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'title': openapi.Schema(type=openapi.TYPE_STRING, description='Phase title'),
                            'symptoms': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_STRING), description='Common symptoms'),
                        },
                    ),
                },
            ),
        ),
        400: openapi.Response('Invalid input data'),
    }
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def predict_cycle(request):
    """
    Predict cycle-related information for the authenticated user.
    """
    try:
        user = request.user
        avg_cycle_length = get_average_cycle_length(user)
        current_day = get_current_day(user)
        ovulation_status = get_ovulation_status(user)
        phase = get_phase(user)

        return Response({
            'avg_cycle_length': avg_cycle_length,
            'current_day': current_day,
            'ovulation_status': ovulation_status,
            'phase': phase,
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(
    method='get',
    operation_description="Fetch period history for the authenticated user.",
    responses={
        200: openapi.Response(
            description="Period history retrieved successfully",
            schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'avg_cycle_length': openapi.Schema(type=openapi.TYPE_NUMBER, description='Average cycle length'),
                    'total_cycles': openapi.Schema(type=openapi.TYPE_INTEGER, description='Total number of cycles'),
                    'period_history': openapi.Schema(
                        type=openapi.TYPE_ARRAY,
                        items=openapi.Items(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'start_date': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='Start date of the period'),
                                'end_date': openapi.Schema(type=openapi.TYPE_STRING, format='date', description='End date of the period'),
                                'cycle_length': openapi.Schema(type=openapi.TYPE_INTEGER, description='Length of the cycle'),
                            },
                        ),
                    ),
                },
            ),
        ),
        404: openapi.Response('No cycle data found'),
        400: openapi.Response('Invalid input data'),
    }
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def period_history(request):
    """
    Fetch period history for the authenticated user.

    Returns:
    - avg_cycle_length: Average length of the user's menstrual cycles.
    - total_cycles: Total number of cycles recorded.
    - period_history: List of cycles with start date, end date, and cycle length.
    """
    try:
        user = request.user
        history = get_period_history(user)

        if not history:
            return Response({'error': 'No cycle data found'}, status=status.HTTP_404_NOT_FOUND)

        return Response(history, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)