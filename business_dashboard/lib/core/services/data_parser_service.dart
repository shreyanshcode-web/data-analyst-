// lib/core/services/data_parser_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

/// Service for parsing different file formats into structured data
class DataParserService {
  static final DataParserService _instance = DataParserService._internal();

  factory DataParserService() {
    return _instance;
  }

  DataParserService._internal();

  /// Parse data from a file based on its format
  Future<Map<String, dynamic>> parseFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    final content = await file.readAsString();

    switch (extension) {
      case 'csv':
        return _parseCSV(content);
      case 'json':
        return _parseJSON(content);
      case 'xlsx':
        final bytes = await file.readAsBytes();
        return _parseExcel(bytes);
      default:
        throw UnsupportedError('Unsupported file format: $extension');
    }
  }

  /// Parse a CSV file into a structured format
  Map<String, dynamic> _parseCSV(String content) {
    try {
      final rows = const CsvToListConverter().convert(content);
      if (rows.isEmpty) {
        return {'error': 'Empty CSV file'};
      }

      final headers = List<String>.from(rows.first);
      final data = rows.skip(1).map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return map;
      }).toList();

      return {
        'type': 'csv',
        'headers': headers,
        'rows': data,
      };
    } catch (e) {
      return {'error': 'Failed to parse CSV: $e'};
    }
  }

  /// Parse a JSON file into a structured format
  Map<String, dynamic> _parseJSON(String content) {
    try {
      final decoded = json.decode(content);
      if (decoded is List) {
        return {
          'type': 'json',
          'rows': decoded,
        };
      } else if (decoded is Map) {
        return {
          'type': 'json',
          'data': decoded,
        };
      }
      return {'error': 'Invalid JSON format'};
    } catch (e) {
      return {'error': 'Failed to parse JSON: $e'};
    }
  }

  /// Parse an Excel file into a structured format
  Map<String, dynamic> _parseExcel(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      final result = <String, dynamic>{
        'type': 'excel',
        'sheets': <String, dynamic>{},
      };

      for (final sheet in excel.tables.entries) {
        final sheetName = sheet.key;
        final rows = sheet.value.rows;
        if (rows.isEmpty) continue;

        final headers = rows.first.map((cell) => cell?.value.toString() ?? '').toList();
        final data = rows.skip(1).map((row) {
          final map = <String, dynamic>{};
          for (var i = 0; i < headers.length && i < row.length; i++) {
            map[headers[i]] = row[i]?.value;
          }
          return map;
        }).toList();

        result['sheets'][sheetName] = {
          'headers': headers,
          'rows': data,
        };
      }

      return result;
    } catch (e) {
      return {'error': 'Failed to parse Excel: $e'};
    }
  }

  /// Parse data from an API response
  Map<String, dynamic> parseApiResponse(dynamic responseData) {
    try {
      if (responseData is List) {
        // Handle array of objects
        if (responseData.isEmpty) {
          throw FormatException('API response contains an empty array');
        }

        // Extract headers from the first object
        final Map<String, dynamic> firstItem = responseData[0] as Map<String, dynamic>;
        final List<String> headers = firstItem.keys.toList();

        return {
          'headers': headers,
          'rows': responseData,
  "format": "api",
          'rowCount': responseData.length,
        };
      } else if (responseData is Map) {
        // Check if this is a paginated response with a data array
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'] as List;
          if (data.isEmpty) {
            throw FormatException('API response data array is empty');
          }

          final Map<String, dynamic> firstItem = data[0] as Map<String, dynamic>;
          final List<String> headers = firstItem.keys.toList();

          return {
            'headers': headers,
            'rows': data,
  "format": "api",
            'rowCount': data.length,
            'metadata': {
              'pagination': responseData['pagination'],
              'total': responseData['total'],
            },
          };
        } else {
          // Simple object
          return {
            'headers': responseData.keys.toList(),
            'rows': [responseData],
  "format": "api",
            'rowCount': 1,
          };
        }
      } else {
        throw FormatException('Unsupported API response structure');
      }
    } catch (e) {
      debugPrint('Error parsing API response: $e');
      rethrow;
    }
  }

  Map<String, dynamic> analyzeData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return {'error': 'No data to analyze'};
    }

    final analysis = <String, dynamic>{};
    final columns = data.first.keys.toList();

    for (final column in columns) {
      final values = data.map((row) => row[column]).toList();
      final columnAnalysis = _analyzeColumn(values);
      analysis[column] = columnAnalysis;
    }

    return {
      'columnAnalysis': analysis,
      'rowCount': data.length,
      'columnCount': columns.length,
    };
  }

  Map<String, dynamic> _analyzeColumn(List<dynamic> values) {
    final numericValues = values.whereType<num>().toList();
    final stringValues = values.whereType<String>().toList();
    final nonNullValues = values.where((v) => v != null).length;

    return {
      'type': _determineColumnType(values),
      'uniqueValues': values.toSet().length,
      'nullCount': values.length - nonNullValues,
      'numeric': numericValues.isNotEmpty ? {
        'min': numericValues.reduce((a, b) => a < b ? a : b),
        'max': numericValues.reduce((a, b) => a > b ? a : b),
        'average': numericValues.reduce((a, b) => a + b) / numericValues.length,
      } : null,
      'string': stringValues.isNotEmpty ? {
        'minLength': stringValues.map((s) => s.length).reduce((a, b) => a < b ? a : b),
        'maxLength': stringValues.map((s) => s.length).reduce((a, b) => a > b ? a : b),
        'mostCommon': _getMostCommonValue(stringValues),
      } : null,
    };
  }

  String _determineColumnType(List<dynamic> values) {
    final nonNullValues = values.where((v) => v != null);
    if (nonNullValues.isEmpty) return 'null';

    if (nonNullValues.every((v) => v is num)) return 'numeric';
    if (nonNullValues.every((v) => v is String)) return 'string';
    if (nonNullValues.every((v) => v is bool)) return 'boolean';
    if (nonNullValues.every((v) => v is DateTime)) return 'datetime';
    
    return 'mixed';
  }

  String? _getMostCommonValue(List<String> values) {
    if (values.isEmpty) return null;

    final frequency = <String, int>{};
    for (final value in values) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }

    String? mostCommon;
    int maxCount = 0;
    
    frequency.forEach((value, count) {
      if (count > maxCount) {
        mostCommon = value;
        maxCount = count;
      }
    });

    return mostCommon;
  }
}