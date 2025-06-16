import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:business_dashboard/core/models/analysis_result.dart';
import 'package:business_dashboard/core/models/data_source.dart';
import 'package:business_dashboard/core/models/insight_item.dart';
import 'package:business_dashboard/core/services/data_parser_service.dart';
import 'package:business_dashboard/core/services/gemini_service.dart';
import 'package:business_dashboard/theme/flutterflow_theme.dart';
import 'package:business_dashboard/widgets/flutterflow/modern_3d_card.dart';
import 'package:dotted_border/dotted_border.dart';

class FlutterFlowDataUpload extends StatefulWidget {
  const FlutterFlowDataUpload({Key? key}) : super(key: key);

  @override
  State<FlutterFlowDataUpload> createState() => _FlutterFlowDataUploadState();
}

class _FlutterFlowDataUploadState extends State<FlutterFlowDataUpload> {
  bool _isUploading = false;
  String? _selectedFileName;
  final List<String> _uploadHistory = [];

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'json'],
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
          _selectedFileName = result.files.single.name;
        });

        // Simulate upload process
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _uploadHistory.insert(0, '${_selectedFileName} - ${DateTime.now().toString().split('.')[0]}');
          _isUploading = false;
          _selectedFileName = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Upload'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Modern3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upload_file, color: Colors.blue, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Business Data',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Supported formats: CSV, XLSX, JSON',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        if (_isUploading) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Uploading $_selectedFileName...',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else
                          ElevatedButton.icon(
                            onPressed: _pickAndUploadFile,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Select File'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_uploadHistory.isNotEmpty) ...[
              Text(
                'Upload History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Modern3DCard(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _uploadHistory.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(_uploadHistory[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _uploadHistory.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 