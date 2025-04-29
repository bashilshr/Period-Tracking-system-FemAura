import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/api/repository.dart';
import 'package:femaura/features/auth/data/models/login_model.dart';
import 'package:femaura/features/auth/data/models/signup_model.dart';

class AuthRepository extends Repository {
  AuthRepository(super.ref);

  Future<LoginModel> login(LoginModel loginModel) async {
    final response = await api.post(Endpoint.login, data: loginModel.toMap());
    return LoginModel.fromAuthMap(response as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await api.post(Endpoint.logout, data: {});
  }

  Future<void> signup(SignupModel signupModel) async {
    await api.post(Endpoint.register, data: signupModel.toMap());
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    await api.post(Endpoint.verifyEmailOtp, data: {'email': email, 'otp': otp});
  }
}

final authRepositoryProvider = RepositoryProvider(AuthRepository.new);
