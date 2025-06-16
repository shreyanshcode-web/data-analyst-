import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class MetricDataTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tableData;

  const MetricDataTableWidget({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  State<MetricDataTableWidget> createState() => _MetricDataTableWidgetState();
}

class _MetricDataTableWidgetState extends State<MetricDataTableWidget> {
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  List<String> _columns = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.tableData.isNotEmpty) {
      _columns = widget.tableData.first.keys.toList();
    }
  }

  int get _totalPages => (widget.tableData.length / _rowsPerPage).ceil();
  
  List<Map<String, dynamic>> get _paginatedData {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > widget.tableData.length 
        ? widget.tableData.length 
        : startIndex + _rowsPerPage;
    
    if (startIndex >= widget.tableData.length) {
      return [];
    }
    
    return widget.tableData.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tableData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataTable(),
        SizedBox(height: 16),
        _buildPagination(),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).brightness == Brightness.light
                ? AppTheme.background
                : AppTheme.surfaceDark,
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 56,
          columns: _columns.map((column) {
            return DataColumn(
              label: Text(
                _formatColumnName(column),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            );
          }).toList(),
          rows: _paginatedData.map((row) {
            return DataRow(
              cells: _columns.map((column) {
                final value = row[column];
                return DataCell(
                  Text(
                    value?.toString() ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${_currentPage * _rowsPerPage + 1} to ${(_currentPage * _rowsPerPage + _paginatedData.length)} of ${widget.tableData.length} entries',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Row(
          children: [
            IconButton(
              icon: const CustomIconWidget(
                iconName: 'chevron_left',
                color: AppTheme.textSecondary,
                size: 24,
              ),
              onPressed: _currentPage > 0 ? _previousPage : null,
              tooltip: 'Previous Page',
              splashRadius: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_currentPage + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textSecondary,
                size: 24,
              ),
              onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
              tooltip: 'Next Page',
              splashRadius: 20,
            ),
          ],
        ),
      ],
    );
  }

  String _formatColumnName(String column) {
    // Convert camelCase or snake_case to Title Case with spaces
    final result = column.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    
    return result.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ').trim();
  }
}