class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiException.fromResponse(dynamic response) {
    return ApiException(
      statusCode: response['status'] ?? 500,
      message: response['message'] ?? 'Unknown error occurred',
      data: response['data'],
    );
  }

  @override
  String toString() => 'ApiException: $statusCode - $message';
} 