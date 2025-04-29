import 'package:femaura/core/api/auth_token_interceptor.dart';
import 'package:femaura/core/api/usecase.dart';
import 'package:femaura/features/auth/data/auth_repository.dart';
import 'package:femaura/features/auth/data/models/login_model.dart';
import 'package:femaura/features/auth/data/models/signup_model.dart';

import '../../../core/utils/secure_storage/secure_storage.dart';

class AuthUsecase extends UseCase {
  AuthUsecase(super.ref);

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  final _secureStorage = SecureStorage();

  Future<void> login({required String email, required String password}) async {
    final loginModel = LoginModel(email: email, password: password);
    final response = await _repo.login(loginModel);
    await _saveToken(response);
  }

  Future<void> _saveToken(LoginModel response) async {
    await _secureStorage.write(
      key: SecureStorageKeys.accessToken,
      value: response.accessToken.toString(),
    );
    await _secureStorage.write(
      key: SecureStorageKeys.refreshToken,
      value: response.refreshToken.toString(),
    );
  }

  bool isLoggedIn() {
    final isAlive = TokenValidator.isTokenAlive(
      _secureStorage.read(key: SecureStorageKeys.refreshToken).toString(),
    );

    if (isAlive) {
      return true;
    }
    logout();
    return false;
  }

  void logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
  }

  Future<void> signup({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    final model = SignupModel(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    await ref.read(authRepositoryProvider).signup(model);
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    await ref.read(authRepositoryProvider).verifyEmailOtp(email, otp);
  }
}

final authUsecaseProvider = UseCaseProvider(AuthUsecase.new);
