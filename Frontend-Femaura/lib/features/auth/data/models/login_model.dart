class LoginModel {
  LoginModel({this.email, this.password, this.accessToken, this.refreshToken});

  final String? email;
  final String? password;

  final String? accessToken;
  final String? refreshToken;

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }

  factory LoginModel.fromAuthMap(Map<String, dynamic> map) {
    return LoginModel(accessToken: map['access'], refreshToken: map['refresh']);
  }
}
