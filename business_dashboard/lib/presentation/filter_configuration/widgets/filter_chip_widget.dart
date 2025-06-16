import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Chip(
      label: Text(label),
      deleteIcon: CustomIconWidget(
        iconName: 'close',
        color: colorScheme.primary,
        size: 18,
      ),
      onDeleted: onRemove,
      backgroundColor: colorScheme.primary.withAlpha(26),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}