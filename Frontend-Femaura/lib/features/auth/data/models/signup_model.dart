class SignupModel {
  const SignupModel({
    this.username,
    this.email,
    this.password,
    this.confirmPassword,
  });

  final String? username;
  final String? email;
  final String? password;
  final String? confirmPassword;

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'confirmpassword': confirmPassword,
    };
  }
}
