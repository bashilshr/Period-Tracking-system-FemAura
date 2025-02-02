# entities/user_entity.py
class UserEntity:
    def __init__(self, id: int, name: str, email: str, password: str, is_active: bool = False):
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.is_active = is_active
