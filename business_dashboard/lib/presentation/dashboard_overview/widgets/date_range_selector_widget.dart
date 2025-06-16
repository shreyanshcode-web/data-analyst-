import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class DateRangeSelectorWidget extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeChanged;

  const DateRangeSelectorWidget({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Preset date range options
    final List<String> dateRanges = ['Today', 'Week', 'Month', 'Quarter'];
    
    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dateRanges.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final range = dateRanges[index];
          final isSelected = range == selectedRange;
          
          return _buildRangeOption(
            context,
            range,
            isSelected,
            theme,
          );
        },
      ),
    );
  }

  Widget _buildRangeOption(
    BuildContext context,
    String range,
    bool isSelected,
    ThemeData theme,
  ) {
    return Material(
      color: isSelected 
          ? theme.colorScheme.primary 
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onRangeChanged(range),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(
            range,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimary 
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}