// Copyright (c) 2023. The Hridayangam Authors. All rights reserved.

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:femaura/core/api/api_client.dart';
import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/utils/secure_storage/secure_storage.dart';
import 'package:femaura/features/auth/data/models/login_model.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor({required this.client});

  SecureStorage get _secureStorage => SecureStorage();

  final APIClient client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = _secureStorage.read(key: SecureStorageKeys.accessToken);
    if (accessToken != null) {
      final accessToken = _secureStorage.read(
        key: SecureStorageKeys.accessToken,
      );
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    log('Authentication Token: ${options.headers['Authorization']}');
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    log('Status Code: ${err.response?.statusCode}');
    if (err.response?.statusCode == 401) {
      final refreshToken =
          _secureStorage.read(key: SecureStorageKeys.refreshToken).toString();
      final accessToken =
          _secureStorage.read(key: SecureStorageKeys.accessToken).toString();

      if (!TokenValidator.isTokenAlive(refreshToken) &&
          refreshToken != 'null') {
        try {
          final response = await client.post(
            Endpoint.refreshToken,
            data: {'token': refreshToken},
            headers: {'Bearer': accessToken},
          );
          final authModel = LoginModel.fromAuthMap(
            response as Map<String, dynamic>,
          );
          if (authModel.accessToken != null && authModel.refreshToken != null) {
            await _stashNewToken(
              authModel.accessToken!,
              authModel.refreshToken!,
            );

            final options = err.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${authModel.accessToken}';
            final retryResponse = await Dio().fetch<void>(options);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await _secureStorage.delete(key: SecureStorageKeys.accessToken);
          await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
        }
      }
    }
    try {
      if (err.response?.data['code'] == 'token_not_valid') {
        handler.next(
          DioException.connectionError(
            requestOptions: RequestOptions(),
            reason: err.response?.data['message'] ?? 'Token not valid',
            error: err,
          ),
        );
      } else {
        handler.next(err);
      }
    } catch (_) {
      handler.next(DioException(requestOptions: RequestOptions()));
    }
  }

  Future<void> _stashNewToken(String accessToken, String refreshToken) async {
    log('Saving new token');
    await _secureStorage.write(
      key: SecureStorageKeys.accessToken,
      value: accessToken,
    );
    await _secureStorage.write(
      key: SecureStorageKeys.refreshToken,
      value: refreshToken,
    );
  }
}

class TokenValidator {
  static bool isTokenAlive(String refreshToken) {
    try {
      final tokenParts = refreshToken.split('.');
      if (tokenParts.length < 3) {
        return false;
      }

      final decodedToken =
          json.decode(
                String.fromCharCodes(
                  base64Url.decode(base64Url.normalize(tokenParts[1])),
                ),
              )
              as Map<String, dynamic>;

      final expirationTimestamp = decodedToken['exp'];
      if (expirationTimestamp is int) {
        final currentTimestamp =
            DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        return currentTimestamp < expirationTimestamp;
      } else {
        return false;
      }
    } on Exception catch (_) {
      return false;
    }
  }
}
