# usecases/user_usecase.py
from repositories.user_repository import UserRepository
from entities.UserEntity import UserEntity
from django.core.mail import send_mail
import hashlib
import random

class UserUsecase:
    @staticmethod
    def signup_user(name: str, email: str, password: str):
        # Hash the password
        hashed_password = hashlib.sha256(password.encode()).hexdigest()

        # Create UserEntity
        user_entity = UserEntity(id=None, name=name, email=email, password=hashed_password)

        # Save user via repository
        user = UserRepository.create_user(user_entity)

        # Generate email verification token
        token = hashlib.sha256(str(random.random()).encode()).hexdigest()
        user.email_verification_token = token
        user.save()

        # Send email
        send_mail(
            subject="Verify your email",
            message=f"Click the link to verify: http://yourdomain.com/verify/{token}",
            from_email="no-reply@yourdomain.com",
            recipient_list=[user.email],
        )

        return user

    @staticmethod
    def login_user(email: str, password: str):
        hashed_password = hashlib.sha256(password.encode()).hexdigest()
        user = UserRepository.get_user_by_email(email)

        if user and user.password == hashed_password:
            if not user.is_active:
                return {"error": "Please verify your email."}
            return {"message": "Login successful."}
        return {"error": "Invalid credentials."}
