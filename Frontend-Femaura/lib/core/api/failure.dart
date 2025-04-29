class Failure implements Exception {
  const Failure({
    required this.message,
    this.error,
    this.code,
    this.stackTrace,
    this.detail,
    this.apiError,
  });

  final String? error;
  final String message;
  final int? code;
  final StackTrace? stackTrace;
  final String? detail;
  final APIError? apiError;
}

class APIFailure extends Failure {
  const APIFailure({
    required super.message,
    super.error,
    super.code,
    super.stackTrace,
    super.detail,
    super.apiError,
  });
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.code,
    super.stackTrace,
    super.detail,
    super.apiError,
  });
}

class APIError {
  APIError({this.message = ''});

  factory APIError.fromMap(Map<String, dynamic> map) {
    return APIError(
      message: map['message'] == null ? '' : map['message'] as String,
    );
  }

  final String message;
}
