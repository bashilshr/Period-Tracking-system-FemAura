# repositories/user_repository.py
from models.UserModel import UserModel
from entities.UserEntity import UserEntity

class UserRepository:
    @staticmethod
    def create_user(user_entity: UserEntity) -> UserModel:
        user = UserModel.objects.create(
            name=user_entity.name,
            email=user_entity.email,
            password=user_entity.password,  # Make sure to hash it
            is_active=user_entity.is_active
        )
        return user

    @staticmethod
    def get_user_by_email(email: str) -> UserModel:
        return UserModel.objects.filter(email=email).first()

    @staticmethod
    def activate_user(email: str) -> bool:
        user = UserModel.objects.filter(email=email).first()
        if user:
            user.is_active = True
            user.save()
            return True
        return False
