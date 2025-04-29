import pytest
from datetime import timedelta
from django.utils import timezone
from rest_framework.exceptions import ValidationError
from UserAuth import serializers
from UserAuth.models import CustomUser, OTP, DailyLog, DailySymptom, DailyMood, Cycle
from UserAuth.serializers import (
    validate_registration_data,
    create_user,
    ExportDataSerializer,
    RequestPasswordResetSerializer,
    NewPasswordSerializer,
    UserProfileSerializer,
    ChangePasswordSerializer,
    DailySymptomSerializer,
    DailyLogSerializer
)

@pytest.mark.django_db
class TestAuthSerializers:
    """Comprehensive tests for all authentication-related serializers"""

    # --- Registration Validation Tests ---
    def test_valid_registration_data(self):
        """Positive test for valid registration data"""
        data = {
            'email': 'test@example.com',
            'password': 'ValidPass123!',
            'confirmpassword': 'ValidPass123!'
        }
        assert validate_registration_data(data) == data

    @pytest.mark.parametrize("invalid_data,expected_error", [
        # Mismatched passwords
        ({'password': 'Pass1!', 'confirmpassword': 'Pass2!'}, 
         "Password and Confirm Password do not match"),
         
        # Missing confirmpassword
        ({'password': 'Pass1!'}, 
         "confirmpassword"),
         
        # Weak password
        ({'password': 'weak', 'confirmpassword': 'weak'}, 
         "This password is too short"),
         
        # Empty data
        ({}, 
         "This field is required")
    ])
    def test_invalid_registration_data(self, invalid_data, expected_error):
        """Negative tests for registration validation"""
        with pytest.raises(ValidationError) as excinfo:
            validate_registration_data(invalid_data)
        assert expected_error in str(excinfo.value)

    # --- User Creation Tests ---
    def test_create_user_success(self):
        """Test successful user creation"""
        data = {
            'email': 'new@example.com',
            'password': 'TestPass123!',
            'confirmpassword': 'TestPass123!'
        }
        user = create_user(data)
        assert user.email == 'new@example.com'
        assert user.check_password('TestPass123!')

    def test_create_user_duplicate_email(self):
        """Test duplicate email prevention"""
        CustomUser.objects.create_user(email='exists@example.com', password='Test123!')
        with pytest.raises(ValidationError) as excinfo:
            create_user({
                'email': 'exists@example.com',
                'password': 'Test123!',
                'confirmpassword': 'Test123!'
            })
        assert "already exists" in str(excinfo.value)

    # --- Password Reset Serializers ---
    def test_request_password_reset_valid(self):
        """Test valid password reset request"""
        serializer = RequestPasswordResetSerializer(data={'email': 'valid@example.com'})
        assert serializer.is_valid()

    def test_request_password_reset_invalid(self):
        """Test invalid email format"""
        serializer = RequestPasswordResetSerializer(data={'email': 'not-an-email'})
        assert not serializer.is_valid()
        assert "Enter a valid email address" in str(serializer.errors)

    # --- New Password Serializer Tests ---
    @pytest.mark.parametrize("invalid_data,expected_error", [
        ({'new_password': 'short', 'confirm_password': 'short'}, "too short"),
        ({'new_password': 'Pass1!', 'confirm_password': 'Different1!'}, "don't match"),
        ({'new_password': 'Pass1!'}, "confirm_password")    
    ])
    def test_new_password_validation(self, invalid_data, expected_error):
        """Test password validation scenarios"""
        data = {
            'email': 'test@example.com',
            'otp': '123456',
            **invalid_data
        }
        serializer = NewPasswordSerializer(data=data)
        assert not serializer.is_valid()
        assert expected_error in str(serializer.errors)

    # --- Daily Log Serializer Tests ---
def test_daily_log_creation(db):
    """Test complete daily log creation"""
    user = CustomUser.objects.create_user(email='log@example.com', password='test123')
    cycle = Cycle.objects.create(
        user=user,
        start_date=timezone.now().date(),
        end_date=timezone.now().date() + timedelta(days=5)
    )

    data = {
        'date': timezone.now().date().isoformat(),
        'experience': 'Had cramps today',
        'symptoms': [{'symptom': 'CRAMPS'}],
        'moods': [{'mood': 'SAD'}]
    }

    serializer = DailyLogSerializer(data=data, context={'user': user})
    assert serializer.is_valid(), serializer.errors
    log = serializer.save(user=user)
    
    assert log.user == user
    assert log.experience == 'Had cramps today'
    assert log.symptoms.first().symptom == 'CRAMPS'
    assert log.moods.first().mood == 'SAD'
    
    def test_invalid_symptom_selection(self):
        """Test invalid symptom choice"""
        serializer = DailySymptomSerializer(data={'symptom': 'INVALID_SYMPTOM'})
        assert not serializer.is_valid()
        assert "Invalid symptom selection" in str(serializer.errors)

    # --- Export Data Serializer Tests ---
    @pytest.mark.parametrize("valid_data", [
        {'format': 'json'},
        {'start_date': '2023-01-01', 'format': 'csv'},
        {'start_date': '2023-01-01', 'end_date': '2023-01-31', 'format': 'pdf'}
    ])
    def test_valid_export_requests(self, valid_data):
        """Test valid export format combinations"""
        serializer = ExportDataSerializer(data=valid_data)
        assert serializer.is_valid()

    @pytest.mark.parametrize("invalid_data,expected_error", [
        ({'format': 'xml'}, "is not a valid choice"),
        ({'start_date': 'invalid-date'}, "Date has wrong format"),
        ({'end_date': '2023-01-01'}, "start_date must be provided")
    ])
    def test_invalid_export_requests(self, invalid_data, expected_error):
        """Test invalid export parameters"""
        serializer = ExportDataSerializer(data=invalid_data)
        assert not serializer.is_valid()
        assert expected_error in str(serializer.errors)

    # --- Edge Case Tests ---
    def test_massive_text_input(self):
        """Test XSS/size protection in experience field"""
        data = {
            'experience': '<script>alert(1)</script>' + 'A'*1000,
            'date': timezone.now().date()
        }
        serializer = DailyLogSerializer(data=data)
        assert not serializer.is_valid()
        assert "Ensure this field has no more than" in str(serializer.errors)

        
    @pytest.mark.parametrize("invalid_data,expected_error", [
        # Invalid email
        ({'username': 'test', 'email': 'not-an-email'}, 
         "Enter a valid email address"),
         
        # Blank username
        ({'username': '', 'email': 'test@example.com'}, 
         "This field may not be blank"),
         
        # Exceeds max length
        ({'username': 'a'*150, 'email': 'test@example.com'}, 
         "Ensure this field has no more than 16 characters")
    ])
    def test_invalid_user_data(self, invalid_data, expected_error):
        """Test invalid user data scenarios"""
        serializer = UserProfileSerializer(data=invalid_data)
        assert not serializer.is_valid()
        assert expected_error in str(serializer.errors)

    @pytest.mark.parametrize("invalid_data,expected_error", [
        # Mismatched new passwords
        ({'old_password': 'Old1!', 'new_password': 'New1!', 'confirm_password': 'Different1!'}, 
         "Passwords don't match"),
         
        # New password same as old
        ({'old_password': 'SamePass1!', 'new_password': 'SamePass1!', 'confirm_password': 'SamePass1!'}, 
         "New password must be different"),
         
        # Missing fields
        ({'old_password': 'Old1!', 'new_password': 'New1!'}, 
         "confirm_password"),
         
        # Weak new password
        ({'old_password': 'Old1!', 'new_password': 'weak', 'confirm_password': 'weak'}, 
         "This password is too short")
    ])
    def test_invalid_password_changes(self, invalid_data, expected_error):
        """Negative tests for password changes"""
        serializer = ChangePasswordSerializer(data=invalid_data)
        assert not serializer.is_valid()
        assert expected_error in str(serializer.errors)