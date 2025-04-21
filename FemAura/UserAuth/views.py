from django.contrib.auth import login, logout, update_session_auth_hash
from django.core.mail import send_mail
from django.http import HttpResponse
from django.contrib.auth import authenticate
from django.conf import settings
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status, serializers
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.tokens import RefreshToken

from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer

import csv
import json
import random
from datetime import datetime
from io import BytesIO

from .models import CustomUser, OTP, Cycle, PasswordResetOTP, Symptom, Mood

from .auth_backends import EmailAuthBackend

from .serializers import (
    NewPasswordSerializer,
    RequestPasswordResetSerializer,
    VerifyOTPSerializer,
    validate_registration_data,
    create_user,
    validate_otp_data,
    validate_login_data,
    UserProfileSerializer, ChangePasswordSerializer
)
from .utils import (
    get_average_cycle_length,
    get_current_day,
    get_ovulation_status,
    get_period_history,
    get_phase,
)

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
                # Resend OTP to inactive user
                user = existing_user
            else:
                user = create_user(validated_data)

            # Generate OTP
            otp = str(random.randint(100000, 999999))  # 6-digit OTP
            OTP.objects.filter(email=user.email).delete()  # Clear old OTPs
            OTP.objects.create(email=user.email, otp=otp)
            
            # Send OTP email
            send_mail(
                'Your OTP Code',
                f'Your verification code: {otp} (valid for 10 mins)',
                settings.EMAIL_HOST_USER,
                [user.email],
                fail_silently=False,
            )
            
            return Response(
                {'message': 'OTP sent to your email. Please verify to complete registration.'},
                status=status.HTTP_201_CREATED
            )
            
        except serializers.ValidationError as e:
            # Handle validation errors from validate_registration_data
            return Response(
                {'error': e.detail if hasattr(e, 'detail') else str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            # Handle unexpected errors
            return Response(
                {'error': 'An error occurred during registration.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
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
    operation_description="Log in a user and return JWT tokens.",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(type=openapi.TYPE_STRING),
            'password': openapi.Schema(type=openapi.TYPE_STRING),
        },
        required=['email'],
    ),
    responses={
        200: openapi.Response(
            description="Login successful",
            schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'access': openapi.Schema(type=openapi.TYPE_STRING),
                    'refresh': openapi.Schema(type=openapi.TYPE_STRING),
                },
            ),
        ),
        400: "Invalid credentials",
    }
)
@api_view(['POST'])
def login_user(request):
    try:
        # Get credentials from request DATA, not POST
        email = request.data.get('email', '').lower().strip()
        password = request.data.get('password', '')
        
        if not email or not password:
            return Response(
                {'error': 'Both email and password are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Explicitly use your backend
        user = authenticate(
            request,
            email=email,
            password=password,
            backend='UserAuth.auth_backends.EmailAuthBackend'
        )
        
        if user is None:
            return Response(
                {'error': 'Invalid email or password'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if not user.is_active:
            return Response(
                {'error': 'Account is not active'},
                status=status.HTTP_403_FORBIDDEN
            )

        refresh = RefreshToken.for_user(user)
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
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
@authentication_classes([JWTAuthentication])
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
    operation_description="Log a new menstrual cycle for the authenticated user",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'start_date': openapi.Schema(
                type=openapi.TYPE_STRING, 
                format='date',
                description='Start date of the period (YYYY-MM-DD)'
            ),
            'end_date': openapi.Schema(
                type=openapi.TYPE_STRING, 
                format='date',
                description='End date of the period (YYYY-MM-DD)'
            ),
        },
        required=['start_date', 'end_date']
    ),
    manual_parameters=[
        openapi.Parameter(
            'Authorization',
            openapi.IN_HEADER,
            description='JWT Token',
            type=openapi.TYPE_STRING,
            required=True
        )
    ],
    responses={
        201: openapi.Response(
            description='Cycle logged successfully',
            examples={
                "application/json": {
                    "message": "Cycle logged successfully"
                }
            }
        ),
        400: openapi.Response(
            description='Bad request',
            examples={
                "application/json": {
                    "error": "end_date must be after start_date"
                }
            }
        ),
        401: openapi.Response(
            description='Unauthorized',
            examples={
                "application/json": {
                    "detail": "Authentication credentials were not provided."
                }
            }
        )
    },
    security=[{'Bearer': []}]
)
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def log_cycle(request):
    """
    Log a new menstrual cycle for the authenticated user.
    Requires JWT authentication.
    """
    try:
        user = request.user
        start_date_str = request.data.get('start_date')
        end_date_str = request.data.get('end_date')

        # Validate input data
        if not start_date_str or not end_date_str:
            return Response(
                {'error': 'Both start_date and end_date are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            # Parse the input strings into date objects
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
        except ValueError:
            return Response(
                {'error': 'Invalid date format. Use YYYY-MM-DD'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Validate date logic
        if end_date <= start_date:
            return Response(
                {'error': 'end_date must be after start_date'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check for overlapping cycles
        overlapping_cycles = Cycle.objects.filter(
            user=user,
            start_date__lte=end_date,
            end_date__gte=start_date
        ).exists()
        
        if overlapping_cycles:
            return Response(
                {'error': 'This cycle overlaps with an existing record'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create and save the Cycle instance
        cycle = Cycle(user=user, start_date=start_date, end_date=end_date)
        cycle.save()

        return Response(
            {
                'message': 'Cycle logged successfully',
                'cycle_id': cycle.id,
                'cycle_length': cycle.cycle_length
            },
            status=status.HTTP_201_CREATED
        )
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_400_BAD_REQUEST
        )
        
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
@authentication_classes([JWTAuthentication])
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
@authentication_classes([JWTAuthentication])
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
    
  
@swagger_auto_schema(
    method='get',
    operation_description="Export complete menstrual cycle history including moods, symptoms, and irregularity data",
    manual_parameters=[
        openapi.Parameter(
            'format',
            openapi.IN_QUERY,
            description="Export format (csv, json, pdf)",
            type=openapi.TYPE_STRING,
            default='pdf',
            enum=['csv', 'json', 'pdf'],
            required=False
        ),
    ],
    responses={
        200: openapi.Response(
            description="File download",
            schema=openapi.Schema(
                type=openapi.TYPE_FILE
            )
        ),
        401: "Unauthorized"
    }
)
@api_view(['GET'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def export_user_data(request):
    format_type = request.query_params.get('format', 'pdf').lower()

    # Validate format
    if format_type not in ['csv', 'json', 'pdf']:
        return Response(
            {'error': 'Invalid format. Choose csv, json, or pdf.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Get all data without date filtering
    all_cycles = Cycle.objects.filter(user=request.user).order_by('start_date')
    irregular_cycles = [
        cycle for cycle in all_cycles 
        if cycle.cycle_length and cycle.cycle_length > 28
    ]

    # Build export structure
    export_data = {
        'summary': {
            'total_cycles': all_cycles.count(),
            'irregular_count': len(irregular_cycles),
            'irregular_dates': [
                {'start_date': cycle.start_date, 'end_date': cycle.end_date} 
                for cycle in irregular_cycles
            ],
            'first_record': all_cycles.first().start_date if all_cycles.exists() else None,
            'last_record': all_cycles.last().start_date if all_cycles.exists() else None
        },
        'cycles': []
    }

    for cycle in all_cycles:
        export_data['cycles'].append({
            'start_date': cycle.start_date,
            'end_date': cycle.end_date,
            'cycle_length': cycle.cycle_length,
            'is_irregular': cycle.cycle_length > 28 if cycle.cycle_length else False,
            'symptoms': list(Symptom.objects.filter(cycle=cycle).values('date', 'symptom')),
            'moods': list(Mood.objects.filter(cycle=cycle).values('date', 'mood'))
        })

    if format_type == 'csv':
        return export_to_csv(export_data)
    elif format_type == 'json':
        return export_to_json(export_data)
    elif format_type == 'pdf':
        return export_to_pdf(export_data, request.user)
    
def export_to_csv(data):
    response = HttpResponse(content_type='text/csv')
    response['Content-Disposition'] = 'attachment; filename="period_data_export.csv"'
    
    writer = csv.writer(response)
    
    # Summary Section
    writer.writerow(['Total Cycles', data['summary']['total_cycles']])
    writer.writerow(['Irregular Cycles', data['summary']['irregular_count']])
    writer.writerow([])
    
    if data['summary']['irregular_dates']:
        writer.writerow(['Irregular Cycle Dates'])
        for irregular in data['summary']['irregular_dates']:
            writer.writerow([f"{irregular['start_date']} to {irregular['end_date']}"])
        writer.writerow([])
    
    # Cycle Details
    writer.writerow(['Cycle Details'])
    writer.writerow(['Start Date', 'End Date', 'Length', 'Irregular?', 'Symptoms', 'Moods'])
    
    for cycle in data['cycles']:
        symptoms = "; ".join(f"{s['date']}: {s['symptom']}" for s in cycle['symptoms'])
        moods = "; ".join(f"{m['date']}: {m['mood']}" for m in cycle['moods'])
        
        writer.writerow([
            cycle['start_date'],
            cycle['end_date'],
            cycle['cycle_length'],
            'Yes' if cycle['is_irregular'] else 'No',
            symptoms,
            moods
        ])
    
    return response

def export_to_json(data):
    response = HttpResponse(
        json.dumps(data, indent=4, default=str),
        content_type='application/json'
    )
    response['Content-Disposition'] = 'attachment; filename="period_data_export.json"'
    return response

def export_to_pdf(data, user):
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    styles = getSampleStyleSheet()
    story = []
    
    # Title
    story.append(Paragraph("Period Data Export", styles['Title']))
    story.append(Spacer(1, 12))
    
    # Summary Section
    story.append(Paragraph("Summary", styles['Heading2']))
    story.append(Paragraph(f"Total Cycles: {data['summary']['total_cycles']}", styles['Normal']))
    story.append(Paragraph(f"Irregular Cycles: {data['summary']['irregular_count']}", styles['Normal']))
    
    if data['summary']['irregular_dates']:
        story.append(Spacer(1, 6))
        story.append(Paragraph("Irregular Dates:", styles['Heading3']))
        for irregular in data['summary']['irregular_dates']:
            story.append(Paragraph(
                f"- {irregular['start_date']} to {irregular['end_date']}",
                styles['Normal']
            ))
    
    story.append(Spacer(1, 12))
    
    # Cycle Details
    story.append(Paragraph("Cycle History", styles['Heading2']))
    for cycle in data['cycles']:
        # Header
        header_text = (
            f"Cycle: {cycle['start_date']} to {cycle['end_date']} | "
            f"Length: {cycle['cycle_length']} days | "
            f"Irregular: {'Yes' if cycle['is_irregular'] else 'No'}"
        )
        story.append(Paragraph(header_text, styles['Heading3']))
        story.append(Spacer(1, 6))
        
        # Symptoms
        if cycle['symptoms']:
            story.append(Paragraph("Symptoms:", styles['Heading4']))
            for symptom in cycle['symptoms']:
                story.append(Paragraph(
                    f"- {symptom['date']}: {symptom['symptom']}",
                    styles['Normal']
                ))
        
        # Moods
        if cycle['moods']:
            story.append(Paragraph("Moods:", styles['Heading4']))
            for mood in cycle['moods']:
                story.append(Paragraph(
                    f"- {mood['date']}: {mood['mood']}",
                    styles['Normal']
                ))
        
        story.append(Spacer(1, 12))
    
    doc.build(story)
    response = HttpResponse(buffer.getvalue(), content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="period_export_{user.username}.pdf"'
    buffer.close()
    return response

#password reset 
@swagger_auto_schema(
    method='post',
    operation_description="Request password reset OTP",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(
                type=openapi.TYPE_STRING,
                format=openapi.FORMAT_EMAIL,
                description="User's registered email"
            ),
        },
        required=['email']
    ),
    responses={
        200: openapi.Response(
            description="OTP sent successfully",
            examples={
                "application/json": {
                    "message": "OTP sent to your email"
                }
            }
        ),
        400: openapi.Response(
            description="Invalid input",
            examples={
                "application/json": {
                    "email": ["This field is required."]
                }
            }
        ),
        404: openapi.Response(
            description="User not found",
            examples={
                "application/json": {
                    "error": "User not found"
                }
            }
        )
    }
)
@api_view(['POST'])
def request_password_reset(request):
    serializer = RequestPasswordResetSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        try:
            user = CustomUser.objects.get(email=email)
            # Delete any existing OTPs
            PasswordResetOTP.objects.filter(user=user).delete()
            
            # Generate 6-digit OTP
            otp = str(random.randint(100000, 999999))
            PasswordResetOTP.objects.create(user=user, otp=otp)
            
            # Send OTP via email
            send_mail(
                'Password Reset OTP',
                f'Your OTP for password reset is: {otp} (valid for 15 minutes)',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )
            return Response({'message': 'OTP sent to your email'}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
@swagger_auto_schema(
    method='post',
    operation_description="Verify password reset OTP",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(
                type=openapi.TYPE_STRING,
                format=openapi.FORMAT_EMAIL,
                description="User's registered email"
            ),
            'otp': openapi.Schema(
                type=openapi.TYPE_STRING,
                max_length=6,
                description="6-digit OTP received via email"
            ),
        },
        required=['email', 'otp']
    ),
    responses={
        200: openapi.Response(
            description="OTP verified successfully",
            examples={
                "application/json": {
                    "message": "OTP verified successfully"
                }
            }
        ),
        400: openapi.Response(
            description="Invalid OTP or expired",
            examples={
                "application/json": {
                    "error": "Invalid OTP"
                }
            }
        ),
        404: openapi.Response(
            description="User not found",
            examples={
                "application/json": {
                    "error": "User not found"
                }
            }
        )
    }
)
@api_view(['POST'])
def verify_otp_password(request):
    serializer = VerifyOTPSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        otp = serializer.validated_data['otp']
        try:
            user = CustomUser.objects.get(email=email)
            reset_otp = PasswordResetOTP.objects.filter(user=user, otp=otp).first()
            
            if not reset_otp:
                return Response({'error': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)
            if reset_otp.is_expired():
                return Response({'error': 'OTP expired'}, status=status.HTTP_400_BAD_REQUEST)
                
            reset_otp.is_verified = True
            reset_otp.save()
            return Response({'message': 'OTP verified successfully'}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(
    method='post',
    operation_description="Set new password after OTP verification",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        properties={
            'email': openapi.Schema(
                type=openapi.TYPE_STRING,
                format=openapi.FORMAT_EMAIL,
                description="User's registered email"
            ),
            'otp': openapi.Schema(
                type=openapi.TYPE_STRING,
                max_length=6,
                description="Verified 6-digit OTP"
            ),
            'new_password': openapi.Schema(
                type=openapi.TYPE_STRING,
                format=openapi.FORMAT_PASSWORD,
                description="New password"
            ),
            'confirm_password': openapi.Schema(
                type=openapi.TYPE_STRING,
                format=openapi.FORMAT_PASSWORD,
                description="Confirm new password"
            ),
        },
        required=['email', 'otp', 'new_password', 'confirm_password']
    ),
    responses={
        200: openapi.Response(
            description="Password reset successful",
            examples={
                "application/json": {
                    "message": "Password reset successful"
                }
            }
        ),
        400: openapi.Response(
            description="Invalid input or OTP",
            examples={
                "application/json": {
                    "error": "Passwords don't match"
                }
            }
        ),
        404: openapi.Response(
            description="User not found",
            examples={
                "application/json": {
                    "error": "User not found"
                }
            }
        )
    }
)
@api_view(['POST'])
def set_new_password(request):
    serializer = NewPasswordSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        otp = serializer.validated_data['otp']
        try:
            user = CustomUser.objects.get(email=email)
            reset_otp = PasswordResetOTP.objects.filter(
                user=user, 
                otp=otp,
                is_verified=True
            ).first()
            
            if not reset_otp:
                return Response({'error': 'Invalid or unverified OTP'}, status=status.HTTP_400_BAD_REQUEST)
            if reset_otp.is_expired():
                return Response({'error': 'OTP expired'}, status=status.HTTP_400_BAD_REQUEST)
                
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            reset_otp.delete()
            return Response({'message': 'Password reset successful'}, status=status.HTTP_200_OK)
        except CustomUser.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method='get',
    operation_description="Get current user profile",
    responses={200: UserProfileSerializer}
)
@swagger_auto_schema(
    method='put',
    operation_description="Update user profile",
    request_body=UserProfileSerializer,
    responses={200: UserProfileSerializer}
)
@swagger_auto_schema(
    method='patch',
    operation_description="Partial update user profile",
    request_body=UserProfileSerializer,
    responses={200: UserProfileSerializer}
)
@api_view(['GET', 'PUT', 'PATCH'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user = request.user
    if request.method == 'GET':
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = UserProfileSerializer(user, data=request.data, partial=request.method == 'PATCH')
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(
    method='post',
    operation_description="Change user password",
    request_body=ChangePasswordSerializer,
    responses={
        200: "Password changed successfully",
        400: "Invalid input"
    }
)
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def change_password(request):
    user = request.user
    serializer = ChangePasswordSerializer(data=request.data)
    
    if serializer.is_valid():
        if not user.check_password(serializer.validated_data['old_password']):
            return Response({"old_password": "Wrong password"}, status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        update_session_auth_hash(request, user)  # Prevent logout
        return Response({"message": "Password changed successfully"}, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(
    method='delete',
    operation_description="Delete user account",
    responses={
        204: "Account deleted successfully",
        400: "Invalid input"
    }
)
@api_view(['DELETE'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def delete_account(request):
    user = request.user
    password = request.data.get('password', '')
    
    if not user.check_password(password):
        return Response({"password": "Wrong password"}, status=status.HTTP_400_BAD_REQUEST)
    
    user.delete()
    return Response({"message": "Account deleted successfully"}, status=status.HTTP_204_NO_CONTENT)


@swagger_auto_schema(
    method='post',
    operation_description="Change user password",
    request_body=ChangePasswordSerializer,
    responses={
        200: "Password changed successfully",
        400: "Invalid input"
    }
)
@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def change_password(request):
    user = request.user
    serializer = ChangePasswordSerializer(data=request.data)
    
    if serializer.is_valid():
        if not user.check_password(serializer.validated_data['old_password']):
            return Response({"old_password": "Wrong password"}, status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        update_session_auth_hash(request, user)  # Prevent logout
        return Response({"message": "Password changed successfully"}, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@swagger_auto_schema(
    method='delete',
    operation_description="Delete user account",
    responses={
        204: "Account deleted successfully",
        400: "Invalid input"
    }
)
@api_view(['DELETE'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def delete_account(request):
    user = request.user
    password = request.data.get('password', '')
    
    if not user.check_password(password):
        return Response({"password": "Wrong password"}, status=status.HTTP_400_BAD_REQUEST)
    
    user.delete()
    return Response({"message": "Account deleted successfully"}, status=status.HTTP_204_NO_CONTENT)


@swagger_auto_schema(
    method='get',
    operation_description="Check authenticated user",
    responses={
        200: openapi.Response('Success', schema=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING),
                'is_active': openapi.Schema(type=openapi.TYPE_BOOLEAN),
            }
        )),
        401: "Unauthorized"
    }
)
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
@api_view(['GET'])
def check_user(request):
    return Response({
        'email': request.user.email,
        'is_active': request.user.is_active,
        'message': 'You are authenticated!'
    })


@swagger_auto_schema(
    method='get',
    operation_description="Get protected user data",
    responses={
        200: openapi.Response('Success'),
        401: "Unauthorized"
    },
    security=[{'Bearer': []}]  # This adds the lock icon in Swagger
)
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
@api_view(['GET'])
def protected_data(request):
    return Response({'data': 'This is protected!'})