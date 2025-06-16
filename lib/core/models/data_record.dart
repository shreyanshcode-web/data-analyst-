class DataRecord {
  final String id;
  final String fileName;
  final String uploadDate;
  final String fileType;
  final int recordCount;
  final String status;

  DataRecord({
    required this.id,
    required this.fileName,
    required this.uploadDate,
    required this.fileType,
    required this.recordCount,
    required this.status,
  });

  factory DataRecord.fromJson(Map<String, dynamic> json) {
    return DataRecord(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      uploadDate: json['uploadDate'] as String,
      fileType: json['fileType'] as String,
      recordCount: json['recordCount'] as int,
      status: json['status'] as String,
    );
  }
} 