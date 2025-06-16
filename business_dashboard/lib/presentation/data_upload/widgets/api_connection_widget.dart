import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:business_dashboard/core/models/analysis_result.dart';
import 'package:business_dashboard/core/models/data_source.dart';
import 'package:business_dashboard/core/services/data_parser_service.dart';
import 'package:business_dashboard/core/services/gemini_service.dart';
import 'package:business_dashboard/theme/app_theme.dart';
import 'package:business_dashboard/widgets/custom_icon_widget.dart';

import 'analysis_result_widget.dart';
import 'data_preview_widget.dart';
import 'file_upload_widget.dart';

class ApiConnectionWidget extends StatefulWidget {
  final TextEditingController apiEndpointController;
  final GlobalKey<FormState> formKey;
  final bool isTestingConnection;
  final bool isConnectionSuccessful;
  final VoidCallback onTestConnection;
  final VoidCallback onFetchData;

  const ApiConnectionWidget({
    Key? key,
    required this.apiEndpointController,
    required this.formKey,
    required this.isTestingConnection,
    required this.isConnectionSuccessful,
    required this.onTestConnection,
    required this.onFetchData,
  }) : super(key: key);

  @override
  State<ApiConnectionWidget> createState() => _ApiConnectionWidgetState();
}

class _ApiConnectionWidgetState extends State<ApiConnectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Connection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: widget.formKey,
              child: TextFormField(
                controller: widget.apiEndpointController,
                decoration: InputDecoration(
                  labelText: 'API Endpoint',
                  hintText: 'Enter your API endpoint URL',
                  border: const OutlineInputBorder(),
                  suffixIcon: widget.isTestingConnection
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            widget.isConnectionSuccessful
                                ? Icons.check_circle
                                : Icons.refresh,
                            color: widget.isConnectionSuccessful
                                ? Colors.green
                                : null,
                          ),
                          onPressed: widget.onTestConnection,
                          tooltip: 'Test Connection',
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an API endpoint';
                  }
                  try {
                    final uri = Uri.parse(value);
                    if (!uri.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                  } catch (e) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the endpoint URL for your data API',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (widget.isConnectionSuccessful)
              ElevatedButton.icon(
                onPressed: widget.onFetchData,
                icon: const Icon(Icons.download),
                label: const Text('Fetch Data'),
              ),
          ],
        ),
      ),
    );
  }
}
