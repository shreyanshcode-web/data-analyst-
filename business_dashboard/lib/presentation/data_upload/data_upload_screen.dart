import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:business_dashboard/core/models/analysis_result.dart';
import 'package:business_dashboard/core/models/data_source.dart';
import 'package:business_dashboard/core/models/uploaded_file.dart';
import 'package:business_dashboard/core/services/gemini_service.dart';
import 'package:business_dashboard/core/services/data_parser_service.dart';
import 'package:business_dashboard/theme/app_theme.dart';
import 'package:business_dashboard/widgets/custom_icon_widget.dart';

import 'package:business_dashboard/presentation/data_upload/widgets/file_upload_widget.dart';
import 'package:business_dashboard/presentation/data_upload/widgets/data_preview_widget.dart';
import 'package:business_dashboard/presentation/data_upload/widgets/analysis_result_widget.dart';
import 'package:business_dashboard/presentation/data_upload/widgets/api_connection_widget.dart';
import 'package:business_dashboard/widgets/modern_3d_screen.dart';
import 'package:business_dashboard/widgets/modern_3d_card.dart';

class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({Key? key}) : super(key: key);

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  final List<UploadedFile> _uploadedFiles = [];
  bool _isUploading = false;

  File? selectedFile;
  String? fileContent;
  AnalysisResult? analysisResult;
  bool isLoading = false;
  DataSource? dataSource;

  final TextEditingController apiEndpointController = TextEditingController();
  final GlobalKey<FormState> apiFormKey = GlobalKey<FormState>();

  bool isTestingConnection = false;
  bool isConnectionSuccessful = false;

  bool _isDragging = false;
  List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv', 'json', 'xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  Future<void> _pickAndUploadFile(FileType fileType, List<String> allowedExtensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
        });

        final file = File(result.files.first.path!);
        final content = await file.readAsString();

        setState(() {
          selectedFile = file;
          fileContent = content;
          _isUploading = false;
        });

        final newDataSource = await _createDataSource();
        if (newDataSource != null) {
          setState(() {
            dataSource = newDataSource;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<DataSource?> _createDataSource() async {
    if (selectedFile == null) return null;
    try {
      final parsedData = await DataParserService().parseFile(selectedFile!);
      final rowCount = parsedData['rows'] is List ? (parsedData['rows'] as List).length : 0;
      
      return DataSource(
        type: DataSourceType.file,
        data: fileContent ?? '',
        fileName: selectedFile!.path.split('/').last,
        fileFormat: selectedFile!.path.split('.').last,
        parsedData: parsedData,
        rowCount: rowCount,
      );
    } catch (e) {
      debugPrint('Data parsing failed: $e');
      return null;
    }
  }

  Future<void> _analyzeData() async {
    if (fileContent == null) return;

    setState(() {
      isLoading = true;
      analysisResult = null;
    });

    try {
      final geminiService = GeminiService();
      final response = await geminiService.analyzeData(
        prompt: 'Analyze this uploaded file and give insights.',
        data: fileContent!,
      );

      setState(() {
        analysisResult = AnalysisResult.fromRawInsights(response.text);
      });
    } catch (e) {
      debugPrint('Analysis failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _testConnection() {
    if (!apiFormKey.currentState!.validate()) return;

    setState(() => isTestingConnection = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isTestingConnection = false;
        isConnectionSuccessful = true;
      });
    });
  }

  void _fetchDataFromApi() {
    debugPrint('Fetching data from: ${apiEndpointController.text}');
    // TODO: Add actual fetching logic here
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Modern3DScreen(
      appBar: AppBar(
        title: const Text('Data Upload'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Data',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Modern3DCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DragTarget<List<PlatformFile>>(
                    onWillAccept: (data) {
                      setState(() {
                        _isDragging = true;
                      });
                      return true;
                    },
                    onAccept: (data) {
                      setState(() {
                        _isDragging = false;
                        _selectedFiles.addAll(data);
                      });
                    },
                    onLeave: (data) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isDragging
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Drag and drop files here',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'or',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.add),
                                label: const Text('Browse Files'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (_selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Selected Files',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return ListTile(
                          leading: Icon(_getFileIcon(file.extension ?? '')),
                          title: Text(file.name),
                          subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFiles.clear();
                            });
                          },
                          child: const Text('Clear All'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle file upload
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Files'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'csv':
        return Icons.table_chart_outlined;
      case 'json':
        return Icons.data_object_outlined;
      case 'xlsx':
      case 'xls':
        return Icons.grid_on_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _UploadOptionCard extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _UploadOptionCard({
    required this.isDarkMode,
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Modern3DCard(
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadedFile {
  final String name;
  final int size;
  final FileType type;
  final DateTime dateUploaded;

  UploadedFile({
    required this.name,
    required this.size,
    required this.type,
    required this.dateUploaded,
  });
}
