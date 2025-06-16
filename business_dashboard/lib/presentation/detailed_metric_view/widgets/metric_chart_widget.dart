import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MetricChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final bool isLineChart;

  const MetricChartWidget({
    Key? key,
    required this.chartData,
    required this.isLineChart,
  }) : super(key: key);

  @override
  State<MetricChartWidget> createState() => _MetricChartWidgetState();
}

class _MetricChartWidgetState extends State<MetricChartWidget> {
  int touchedIndex = -1;
  
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Performance Trend',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        _buildLegendItem(AppTheme.primary, 'Actual'),
                        SizedBox(width: 16),
                        _buildLegendItem(AppTheme.chart3, 'Target'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Semantics(
                  label: "Sales Performance Chart for Q2",
                  child: widget.isLineChart ? _buildLineChart() : _buildBarChart(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final index = flSpot.x.toInt();
                if (index >= 0 && index < widget.chartData.length) {
                  final data = widget.chartData[index];
                  final value = barSpot.barIndex == 0 
                      ? '\$${data['value']}' 
                      : '\$${data['target']}';
                  return LineTooltipItem(
                    '${data['date']}: $value',
                    Theme.of(context).textTheme.bodySmall!,
                  );
                }
                return null;
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 3 != 0) return const SizedBox.shrink();
                final index = value.toInt();
                if (index >= 0 && index < widget.chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.chartData[index]['date'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '\$${value ~/ 1000}k',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppTheme.divider, width: 1),
            left: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        minX: 0,
        maxX: widget.chartData.length.toDouble() - 1,
        minY: 35000,
        maxY: 70000,
        lineBarsData: [
          // Actual line
          LineChartBarData(
            spots: List.generate(widget.chartData.length, (index) {
              return FlSpot(
                index.toDouble(),
                (widget.chartData[index]['value'] as num).toDouble(),
              );
            }),
            isCurved: true,
            color: AppTheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primary.withAlpha(26),
            ),
          ),
          // Target line
          LineChartBarData(
            spots: List.generate(widget.chartData.length, (index) {
              return FlSpot(
                index.toDouble(),
                (widget.chartData[index]['target'] as num).toDouble(),
              );
            }),
            isCurved: true,
            color: AppTheme.chart3,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).cardColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x;
              if (index >= 0 && index < widget.chartData.length) {
                final data = widget.chartData[index];
                final value = rodIndex == 0 
                    ? '\$${data['value']}' 
                    : '\$${data['target']}';
                return BarTooltipItem(
                  '${data['date']}: $value',
                  Theme.of(context).textTheme.bodySmall!,
                );
              }
              return null;
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (barTouchResponse?.spot != null && event is! FlTapUpEvent) {
                touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
              } else {
                touchedIndex = -1;
              }
            });
          },
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 3 != 0) return const SizedBox.shrink();
                final index = value.toInt();
                if (index >= 0 && index < widget.chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.chartData[index]['date'],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '\$${value ~/ 1000}k',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppTheme.divider, width: 1),
            left: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        barGroups: List.generate(widget.chartData.length, (index) {
          final data = widget.chartData[index];
          final value = (data['value'] as num).toDouble();
          final target = (data['target'] as num).toDouble();
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: touchedIndex == index ? AppTheme.primary : AppTheme.primary.withAlpha(179),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: target,
                  color: AppTheme.chart3.withAlpha(77),
                ),
              ),
            ],
          );
        }),
        minY: 35000,
        maxY: 70000,
      ),
    );
  }
}