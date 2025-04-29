import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:femaura/core/api/auth_token_interceptor.dart';
import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/api/failure.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

class APIClient {
  APIClient({required String baseUrl})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: false,
          printErrorHeaders: false,
          printErrorMessage: false,
        ),
      ),
    );
    if (baseUrl.isNotEmpty) {
      _dio.interceptors.add(AuthTokenInterceptor(client: this));
    }
  }

  final Dio _dio;

  Future<T> get<T>(
    EndpointMixin endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? params,
  }) async {
    final res = await _request(
      endpoint,
      'GET',
      queryParameters: queryParameters,
      params: params,
    );
    return res;
  }

  Future<T> post<T>(
    EndpointMixin endpoint, {
    required Object? data,
    Map<String, dynamic>? headers,
    Map<String, String>? params,
  }) async {
    final res = await _request(
      endpoint,
      'POST',
      data: data,
      params: params,
      headers: headers,
    );
    return res;
  }

  Future<dynamic> _request(
    EndpointMixin endpoint,
    String method, {
    Object? data,
    Map<String, String>? params,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final updatedPath = endpoint.path.replaceAllMapped(RegExp(r':(\w+)'), (
        match,
      ) {
        return params?[match.group(1)] ?? match.group(0)!;
      });

      final filteredQueryParameters =
          queryParameters?.entries
              .where((entry) => entry.value != null)
              .map((entry) => MapEntry(entry.key, entry.value))
              .toList();

      log('Requesting Headers: $headers');

      final response = await _dio.request<dynamic>(
        '/$updatedPath',
        data: data,
        queryParameters:
            filteredQueryParameters != null
                ? Map.fromEntries(filteredQueryParameters)
                : null,
        options: Options(method: method, headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      _handleException(e);
    }
  }

  Never _handleException(DioException e) {
    if (RegExp('amazonaws').hasMatch(e.requestOptions.path)) {
      throw APIFailure(
        message:
            'There was an error uploading the file to the server. Please try again later.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      );
    }
    throw switch (e.type) {
      DioExceptionType.connectionTimeout => APIFailure(
        message: 'The connection to the server timed out.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      ),
      DioExceptionType.sendTimeout => APIFailure(
        message: 'The connection to the server timed out.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      ),
      DioExceptionType.receiveTimeout => APIFailure(
        message:
            'The connection succeeded, but the server did not send any data.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      ),
      DioExceptionType.badResponse => APIFailure(
        error: (e.response!.data as Map<String, dynamic>)['error'].toString(),
        message:
            (e.response!.data as Map<String, dynamic>)['message'].toString(),
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
        apiError: APIError.fromMap(e.response!.data as Map<String, dynamic>),
      ),
      DioExceptionType.cancel => APIFailure(
        message: 'The request was cancelled.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      ),
      DioExceptionType.connectionError => NetworkFailure(
        message:
            e.message?.toLowerCase().contains('token') ?? false
                ? 'Token Access Expired. Please Login Again.'
                : 'Please check your internet connection',
      ),
      _ => APIFailure(
        message: 'Something went wrong. Try again later.',
        stackTrace: e.stackTrace,
        code: e.response?.statusCode,
      ),
    };
  }
}
