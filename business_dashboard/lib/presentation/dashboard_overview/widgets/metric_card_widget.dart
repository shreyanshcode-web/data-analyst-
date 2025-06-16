import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class MetricCardWidget extends StatelessWidget {
  final Map<String, dynamic> metric;
  final VoidCallback onTap;

  const MetricCardWidget({
    Key? key,
    required this.metric,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Extract metric data
    final String name = metric['name'] as String;
    final dynamic value = metric['value'];
    final String format = metric['format'] as String;
    final double changePercentage = metric['changePercentage'] as double;
    final String changeDirection = metric['changeDirection'] as String;
    final List<FlSpot> timeSeriesData = metric['timeSeriesData'] as List<FlSpot>;
    final Color metricColor = metric['color'] as Color;
    
    // Format value based on format type
    final String formattedValue = _formatValue(value, format);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedValue,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildChangeIndicator(
                    context, 
                    changePercentage, 
                    changeDirection,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: _buildSparkline(
                    context,
                    timeSeriesData,
                    metricColor,
                    isDarkMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(dynamic value, String format) {
    switch (format) {
      case 'currency':
        return '\$${value is int ? value.toString() : value.toStringAsFixed(2)}';
      case 'percentage':
        return '${value is int ? value.toString() : value.toStringAsFixed(2)}%';
      case 'number':
      default:
        if (value is int) {
          return _formatNumber(value);
        } else if (value is double) {
          return _formatNumber(value.round());
        }
        return value.toString();
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildChangeIndicator(
    BuildContext context, 
    double changePercentage, 
    String changeDirection,
  ) {
    final theme = Theme.of(context);
    final isPositive = changeDirection == 'up';
    final color = isPositive ? AppTheme.success : AppTheme.error;
    final iconName = isPositive ? 'arrow_upward' : 'arrow_downward';
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 12,
          ),
          SizedBox(width: 4),
          Text(
            '${changePercentage.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkline(
    BuildContext context, 
    List<FlSpot> data, 
    Color color,
    bool isDarkMode,
  ) {
    return Semantics(
      label: "Trend chart for metric",
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          minX: 0,
          maxX: data.length - 1.0,
          minY: data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withAlpha(38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}