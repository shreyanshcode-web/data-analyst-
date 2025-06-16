import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';

/// Service class for interacting with the Gemini API
class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String _apiKey;
  late final Dio _dio;

  GeminiService({String? apiKey}) : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please set it in .env file or pass it to the constructor.');
    }
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        queryParameters: {'key': _apiKey},
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<AnalysisResult> analyzeData({
    required String prompt,
    required String data,
  }) async {
    try {
      final response = await _dio.post(
        '/models/gemini-pro:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '''
Analyze this business data and provide insights:

Data:
$data

Please provide insights in this format:
Key Finding: Description
Trend Analysis: Description
Risk Assessment: Description
Recommendation: Description
'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final candidates = responseData['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates.first['content'];
          final text = content['parts'][0]['text'] as String;
          return AnalysisResult.fromRawInsights(text);
        }
      }

      throw Exception('Failed to analyze data: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error while analyzing data: ${e.message}');
    } catch (e) {
      throw Exception('Error analyzing data: $e');
    }
  }

  Dio get dio => _dio;
}
