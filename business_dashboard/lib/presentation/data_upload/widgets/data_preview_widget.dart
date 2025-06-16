import 'package:flutter/material.dart';
import 'package:business_dashboard/core/models/data_source.dart';

class DataPreviewWidget extends StatelessWidget {
  final DataSource dataSource;
  final VoidCallback? onAnalyze;
  final bool isAnalyzing;

  const DataPreviewWidget({
    Key? key,
    required this.dataSource,
    this.onAnalyze,
    this.isAnalyzing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Preview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    if (dataSource.type == DataSourceType.file)
                      Text(
                        '${dataSource.fileName} (${dataSource.fileFormat?.toUpperCase() ?? "UNKNOWN"})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                if (onAnalyze != null)
                  ElevatedButton.icon(
                    onPressed: isAnalyzing ? null : onAnalyze,
                    icon: isAnalyzing 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.analytics),
                    label: Text(isAnalyzing ? 'Analyzing...' : 'Analyze'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataPreview(context),
            if (dataSource.rowCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${dataSource.rowCount} rows found',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataPreview(BuildContext context) {
    final previewData = dataSource.parsedData != null 
        ? dataSource.parsedData.toString()
        : dataSource.data;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            previewData,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ),
      ),
    );
  }
}
