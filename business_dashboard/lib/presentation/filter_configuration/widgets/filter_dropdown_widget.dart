import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterDropdownWidget extends StatelessWidget {
  final String label;
  final String hint;
  final List<Map<String, dynamic>> options;
  final String? selectedValue;
  final String? errorText;
  final Function(String?) onChanged;

  const FilterDropdownWidget({
    Key? key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedValue,
    this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(hint),
          decoration: InputDecoration(
            errorText: errorText,
            prefixIcon: CustomIconWidget(
              iconName: _getIconForLabel(label),
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          isExpanded: true,
          icon: CustomIconWidget(
            iconName: 'arrow_drop_down',
            color: theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'] as String,
              child: Text(option['name'] as String),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'department':
        return 'business';
      case 'time period':
        return 'date_range';
      case 'metric type':
        return 'analytics';
      default:
        return 'filter_list';
    }
  }
}