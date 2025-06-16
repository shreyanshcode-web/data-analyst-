import 'package:file_picker/file_picker.dart';

class UploadedFile {
  final String name;
  final int size;
  final FileType type;
  final DateTime dateUploaded;
  final String? path;
  final String? mimeType;

  const UploadedFile({
    required this.name,
    required this.size,
    required this.type,
    required this.dateUploaded,
    this.path,
    this.mimeType,
  });

  factory UploadedFile.fromPlatformFile(PlatformFile file) {
    return UploadedFile(
      name: file.name,
      size: file.size,
      type: file.extension != null 
          ? _getFileType(file.extension!) 
          : FileType.any,
      dateUploaded: DateTime.now(),
      path: file.path,
      mimeType: file.extension != null 
          ? _getMimeType(file.extension!) 
          : null,
    );
  }

  static FileType _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'csv':
      case 'xlsx':
      case 'xls':
        return FileType.custom;
      case 'json':
        return FileType.custom;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FileType.image;
      default:
        return FileType.any;
    }
  }

  static String? _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'csv':
        return 'text/csv';
      case 'xlsx':
      case 'xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'json':
        return 'application/json';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return null;
    }
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
} 