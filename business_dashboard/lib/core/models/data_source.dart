// lib/core/models/data_source.dart
import 'dart:io';

/// Represents the source of data (file upload or API)
class DataSource {
  final DataSourceType type;
  final String data;
  final String? fileName;
  final String? fileFormat;
  final Map<String, dynamic> parsedData;
  final int rowCount;

  DataSource({
    required this.type,
    required this.data,
    this.fileName,
    this.fileFormat,
    required this.parsedData,
    required this.rowCount,
  });

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      type: DataSourceType.values.firstWhere(
        (e) => e.toString() == 'DataSourceType.${json['type']}',
      ),
      data: json['data'],
      fileName: json['fileName'],
      fileFormat: json['fileFormat'],
      parsedData: json['parsedData'],
      rowCount: json['rowCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
      'fileName': fileName,
      'fileFormat': fileFormat,
      'parsedData': parsedData,
      'rowCount': rowCount,
    };
  }

  /// Creates a file-based data source
  static DataSource fromFile(File file, {
    String? fileFormat,
    dynamic parsedData,
    int? rowCount,
  }) {
    final String fileName = file.path.split('/').last;
    final String detectedFormat = fileFormat ?? fileName.split('.').last.toLowerCase();

    return DataSource(
      type: DataSourceType.file,
      data: file.path,
      fileName: fileName,
      fileFormat: detectedFormat,
      parsedData: parsedData,
      rowCount: rowCount ?? 0,
    );
  }

  /// Creates an API-based data source
  static DataSource fromApi(String apiEndpoint, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
    dynamic parsedData,
    int? rowCount,
  }) {
    return DataSource(
      type: DataSourceType.api,
      data: apiEndpoint,
      fileName: '',
      fileFormat: '',
      parsedData: parsedData,
      rowCount: rowCount ?? 0,
    );
  }

  /// Create a copy of this data source with some fields updated
  DataSource copyWith({
    DataSourceType? type,
    String? data,
    String? fileName,
    String? fileFormat,
    Map<String, dynamic>? parsedData,
    int? rowCount,
  }) {
    return DataSource(
      type: type ?? this.type,
      data: data ?? this.data,
      fileName: fileName ?? this.fileName,
      fileFormat: fileFormat ?? this.fileFormat,
      parsedData: parsedData ?? this.parsedData,
      rowCount: rowCount ?? this.rowCount,
    );
  }
}

/// Types of data sources
enum DataSourceType {
  file,
  api,
  database
}