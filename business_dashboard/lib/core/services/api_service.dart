// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for handling API requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio _dio = Dio();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint(object.toString()),
    ));
  }

  /// Fetch data from an API endpoint
  Future<dynamic> fetchData(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    int timeout = 30000,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
      );

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio specific exceptions
      debugPrint('DioException: ${e.message}');
      if (e.response != null) {
        throw ApiException(
          statusCode: e.response?.statusCode ?? 500,
          message: e.response?.data?['message'] ?? e.message ?? 'Unknown error',
        );
      } else {
        throw ApiException(
          statusCode: 500,
          message: e.message ?? 'Network error occurred',
        );
      }
    } catch (e) {
      // Handle all other exceptions
      debugPrint('Unexpected error: $e');
      throw ApiException(
        statusCode: 500,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Test the connection to an API endpoint
  Future<bool> testConnection(String endpoint, {
    Map<String, dynamic>? headers,
    int timeout = 5000,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
      );

      final response = await _dio.head(
        endpoint,
        options: options,
      );

      return response.statusCode == 200 || 
             response.statusCode == 204 ||
             response.statusCode == 201;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}