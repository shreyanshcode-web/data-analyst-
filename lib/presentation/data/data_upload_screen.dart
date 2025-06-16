import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/flutterflow/modern_3d_card.dart';
import '../../core/models/data_record.dart';
import 'package:intl/intl.dart';

class DataUploadScreen extends StatefulWidget {
  const DataUploadScreen({Key? key}) : super(key: key);

  @override
  State<DataUploadScreen> createState() => _DataUploadScreenState();
}

class _DataUploadScreenState extends State<DataUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  List<DataRecord> _recentUploads = [];
  String _selectedDataType = 'Sales Data';
  String _selectedFrequency = 'Daily';
  bool _autoProcess = true;
  String _notes = '';
  final _formKey = GlobalKey<FormState>();

  final List<String> _dataTypes = [
    'Sales Data',
    'Customer Data',
    'Inventory Data',
    'Financial Reports',
    'Marketing Metrics',
    'Employee Data',
  ];

  final List<String> _frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
    'One-time',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentUploads();
  }

  Future<void> _loadRecentUploads() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _recentUploads = [
        DataRecord(
          id: '1',
          fileName: 'sales_data_2024.csv',
          uploadDate: '2024-03-20',
          fileType: 'CSV',
          recordCount: 1500,
          status: 'Processed',
        ),
        DataRecord(
          id: '2',
          fileName: 'customer_data.xlsx',
          uploadDate: '2024-03-19',
          fileType: 'Excel',
          recordCount: 2300,
          status: 'Processing',
        ),
      ];
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    // Simulate file upload and processing
    await Future.delayed(const Duration(seconds: 2));

    final newRecord = DataRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: _selectedFile!.name,
      uploadDate: DateTime.now().toString().split(' ')[0],
      fileType: _selectedFile!.extension?.toUpperCase() ?? 'Unknown',
      recordCount: 0,
      status: 'Processing',
    );

    setState(() {
      _recentUploads = [newRecord, ..._recentUploads];
      _isUploading = false;
      _selectedFile = null;
      _notes = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File uploaded successfully!')),
    );
  }

  Widget _buildUploadSection() {
    return Modern3DCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload New Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDataType,
                      decoration: const InputDecoration(
                        labelText: 'Data Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _dataTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDataType = value!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a data type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Upload Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: _frequencies.map((frequency) {
                        return DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedFrequency = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Add any additional information about this data...',
                ),
                onChanged: (value) => _notes = value,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Auto-process after upload'),
                subtitle: const Text('Automatically process and analyze the data'),
                value: _autoProcess,
                onChanged: (value) => setState(() => _autoProcess = value),
              ),
              const Divider(),
              const SizedBox(height: 16),
              if (_selectedFile != null) ...[
                ListTile(
                  leading: Icon(
                    _selectedFile!.extension == 'csv' 
                        ? Icons.table_chart 
                        : Icons.table_view,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(_selectedFile!.name),
                  subtitle: Text(
                    'Size: ${(_selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Choose File'),
                    onPressed: _isUploading ? null : _pickFile,
                  ),
                  const SizedBox(width: 16),
                  if (_selectedFile != null)
                    ElevatedButton.icon(
                      icon: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                      onPressed: _isUploading ? null : _uploadFile,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Uploads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              onPressed: _loadRecentUploads,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentUploads.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final record = _recentUploads[index];
            return Modern3DCard(
              child: ExpansionTile(
                leading: Icon(
                  record.fileType == 'CSV' ? Icons.table_chart : Icons.table_view,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(record.fileName),
                subtitle: Text(
                  'Uploaded: ${record.uploadDate}',
                ),
                trailing: Chip(
                  label: Text(record.status),
                  backgroundColor: record.status == 'Processed'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: record.status == 'Processed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('File Type: ${record.fileType}'),
                        Text('Record Count: ${record.recordCount}'),
                        Text('Upload Date: ${record.uploadDate}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                              onPressed: () {
                                // TODO: Implement download
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              onPressed: () {
                                // TODO: Implement delete
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Upload'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Upload Guidelines'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Supported File Types:'),
                        Text('• CSV (.csv)'),
                        Text('• Excel (.xlsx, .xls)'),
                        SizedBox(height: 16),
                        Text('File Requirements:'),
                        Text('• Maximum file size: 50MB'),
                        Text('• Must contain headers'),
                        Text('• UTF-8 encoding recommended'),
                        SizedBox(height: 16),
                        Text('Processing Time:'),
                        Text('• Small files (< 1MB): ~1 minute'),
                        Text('• Large files (> 10MB): 5-10 minutes'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(),
            const SizedBox(height: 32),
            _buildRecentUploadsSection(),
          ],
        ),
      ),
    );
  }
} 