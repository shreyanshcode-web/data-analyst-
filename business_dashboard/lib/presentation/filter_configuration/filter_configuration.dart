import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/filter_dropdown_widget.dart';
import 'widgets/filter_chip_widget.dart';
import 'widgets/filter_dropdown_widget.dart';

class FilterConfiguration extends StatefulWidget {
  const FilterConfiguration({Key? key}) : super(key: key);

  @override
  State<FilterConfiguration> createState() => _FilterConfigurationState();
}

class _FilterConfigurationState extends State<FilterConfiguration> {
  bool isLoading = true;
  String? errorMessage;
  
  // Selected filter values
  String? selectedDepartment;
  String? selectedTimePeriod;
  String? selectedMetricType;
  
  // Validation errors
  String? departmentError;
  String? timePeriodError;
  String? metricTypeError;
  
  // Filter options
  final List<Map<String, dynamic>> departmentOptions = [];
  final List<Map<String, dynamic>> timePeriodOptions = [];
  final List<Map<String, dynamic>> metricTypeOptions = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _loadSavedFilters();
  }

  Future<void> _loadFilterOptions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Simulate API call to fetch filter options
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data for filter options
      final mockFilterOptions = _getMockFilterOptions();
      
      setState(() {
        departmentOptions.addAll(mockFilterOptions['departments'] as List<Map<String, dynamic>>);
        timePeriodOptions.addAll(mockFilterOptions['timePeriods'] as List<Map<String, dynamic>>);
        metricTypeOptions.addAll(mockFilterOptions['metricTypes'] as List<Map<String, dynamic>>);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load filter options. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        selectedDepartment = prefs.getString('selectedDepartment');
        selectedTimePeriod = prefs.getString('selectedTimePeriod');
        selectedMetricType = prefs.getString('selectedMetricType');
      });
    } catch (e) {
      // If there's an error loading saved filters, we'll just use the defaults
      debugPrint('Error loading saved filters: $e');
    }
  }

  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (selectedDepartment != null) {
        await prefs.setString('selectedDepartment', selectedDepartment!);
      }
      
      if (selectedTimePeriod != null) {
        await prefs.setString('selectedTimePeriod', selectedTimePeriod!);
      }
      
      if (selectedMetricType != null) {
        await prefs.setString('selectedMetricType', selectedMetricType!);
      }
    } catch (e) {
      debugPrint('Error saving filters: $e');
    }
  }

  void _resetFilters() {
    setState(() {
      selectedDepartment = null;
      selectedTimePeriod = null;
      selectedMetricType = null;
      departmentError = null;
      timePeriodError = null;
      metricTypeError = null;
    });
  }

  bool _validateFilters() {
    bool isValid = true;
    
    setState(() {
      // Validate department
      if (selectedDepartment == null) {
        departmentError = 'Please select a department';
        isValid = false;
      } else {
        departmentError = null;
      }
      
      // Validate time period
      if (selectedTimePeriod == null) {
        timePeriodError = 'Please select a time period';
        isValid = false;
      } else {
        timePeriodError = null;
      }
      
      // Validate metric type
      if (selectedMetricType == null) {
        metricTypeError = 'Please select a metric type';
        isValid = false;
      } else {
        metricTypeError = null;
      }
    });
    
    return isValid;
  }

  void _applyFilters() {
    if (_validateFilters()) {
      _saveFilters();
      
      // Close the modal and return to dashboard with applied filters
      Navigator.pop(context, {
        'department': selectedDepartment,
        'timePeriod': selectedTimePeriod,
        'metricType': selectedMetricType,
      });
    }
  }

  Map<String, dynamic> _getMockFilterOptions() {
    return {
      'departments': [
        {'id': 'sales', 'name': 'Sales'},
        {'id': 'marketing', 'name': 'Marketing'},
        {'id': 'finance', 'name': 'Finance'},
        {'id': 'operations', 'name': 'Operations'},
        {'id': 'hr', 'name': 'Human Resources'},
        {'id': 'it', 'name': 'Information Technology'},
      ],
      'timePeriods': [
        {'id': 'today', 'name': 'Today'},
        {'id': 'yesterday', 'name': 'Yesterday'},
        {'id': 'this_week', 'name': 'This Week'},
        {'id': 'last_week', 'name': 'Last Week'},
        {'id': 'this_month', 'name': 'This Month'},
        {'id': 'last_month', 'name': 'Last Month'},
        {'id': 'this_quarter', 'name': 'This Quarter'},
        {'id': 'last_quarter', 'name': 'Last Quarter'},
        {'id': 'this_year', 'name': 'This Year'},
        {'id': 'last_year', 'name': 'Last Year'},
        {'id': 'custom', 'name': 'Custom Range'},
      ],
      'metricTypes': [
        {'id': 'revenue', 'name': 'Revenue'},
        {'id': 'profit', 'name': 'Profit'},
        {'id': 'conversion', 'name': 'Conversion Rate'},
        {'id': 'customer_acquisition', 'name': 'Customer Acquisition'},
        {'id': 'customer_retention', 'name': 'Customer Retention'},
        {'id': 'average_order_value', 'name': 'Average Order Value'},
        {'id': 'employee_performance', 'name': 'Employee Performance'},
        {'id': 'inventory_turnover', 'name': 'Inventory Turnover'},
        {'id': 'website_traffic', 'name': 'Website Traffic'},
        {'id': 'social_media_engagement', 'name': 'Social Media Engagement'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 32,
        vertical: 24,
      ),
      child: Container(
        width: isSmallScreen ? double.infinity : 500,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: 90.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildContent(theme, isSmallScreen),
              ),
            ),
            _buildFooter(theme, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter Dashboard',
            style: theme.textTheme.titleLarge,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isSmallScreen) {
    if (isLoading) {
      return SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }
    
    if (errorMessage != null) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: AppTheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFilterOptions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize your dashboard view by selecting filters below:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Department Filter
          FilterDropdownWidget(
            label: 'Department',
            hint: 'Select department',
            options: departmentOptions,
            selectedValue: selectedDepartment,
            errorText: departmentError,
            onChanged: (value) {
              setState(() {
                selectedDepartment = value;
                if (value != null) {
                  departmentError = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Time Period Filter
          FilterDropdownWidget(
            label: 'Time Period',
            hint: 'Select time period',
            options: timePeriodOptions,
            selectedValue: selectedTimePeriod,
            errorText: timePeriodError,
            onChanged: (value) {
              setState(() {
                selectedTimePeriod = value;
                if (value != null) {
                  timePeriodError = null;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Metric Type Filter
          FilterDropdownWidget(
            label: 'Metric Type',
            hint: 'Select metric type',
            options: metricTypeOptions,
            selectedValue: selectedMetricType,
            errorText: metricTypeError,
            onChanged: (value) {
              setState(() {
                selectedMetricType = value;
                if (value != null) {
                  metricTypeError = null;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          
          // Selected Filters Preview
          if (selectedDepartment != null || selectedTimePeriod != null || selectedMetricType != null)
            _buildSelectedFiltersPreview(theme),
        ],
      ),
    );
  }

  Widget _buildSelectedFiltersPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Filters:',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (selectedDepartment != null)
              FilterChipWidget(
                label: _getOptionName(departmentOptions, selectedDepartment!),
                onRemove: () {
                  setState(() {
                    selectedDepartment = null;
                  });
                },
              ),
            if (selectedTimePeriod != null)
              FilterChipWidget(
                label: _getOptionName(timePeriodOptions, selectedTimePeriod!),
                onRemove: () {
                  setState(() {
                    selectedTimePeriod = null;
                  });
                },
              ),
            if (selectedMetricType != null)
              FilterChipWidget(
                label: _getOptionName(metricTypeOptions, selectedMetricType!),
                onRemove: () {
                  setState(() {
                    selectedMetricType = null;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  String _getOptionName(List<Map<String, dynamic>> options, String id) {
    final option = options.firstWhere(
      (option) => option['id'] == id,
      orElse: () => {'name': 'Unknown'},
    );
    return option['name'] as String;
  }

  Widget _buildFooter(ThemeData theme, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: isSmallScreen
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
    );
  }
}