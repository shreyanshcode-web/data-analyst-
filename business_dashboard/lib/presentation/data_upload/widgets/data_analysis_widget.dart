import 'package:flutter/material.dart';
import '../../../widgets/modern_3d_card.dart';
import 'package:fl_chart/fl_chart.dart';

class DataAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDarkMode;

  const DataAnalysisWidget({
    Key? key,
    required this.data,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Modern3DCard(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  isDarkMode: isDarkMode,
                  title: 'Total Records',
                  value: data['totalRecords']?.toString() ?? '0',
                  icon: Icons.analytics,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  isDarkMode: isDarkMode,
                  title: 'Data Types',
                  value: data['dataTypes']?.length?.toString() ?? '0',
                  icon: Icons.category,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  isDarkMode: isDarkMode,
                  title: 'Missing Values',
                  value: data['missingValues']?.toString() ?? '0',
                  icon: Icons.warning_amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (data['chartData'] != null) ...[
            Text(
              'Data Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            data['chartData'][value.toInt()]['label'] ?? '',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    data['chartData'].length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data['chartData'][i]['value']?.toDouble() ?? 0,
                          color: Theme.of(context).primaryColor,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isDarkMode;
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    Key? key,
    required this.isDarkMode,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Modern3DCard(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 