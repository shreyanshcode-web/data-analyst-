import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/modern_3d_card.dart';
import '../../../theme/app_theme.dart';
import 'dart:math' as math;

class DashboardWidget {
  final String id;
  final String title;
  final IconData icon;
  final Widget content;
  final bool isRealTime;

  const DashboardWidget({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
    this.isRealTime = false,
  });
}

class CustomizableDashboardWidget extends StatefulWidget {
  final List<DashboardWidget> availableWidgets;
  final List<String> activeWidgets;
  final Function(List<String>)? onWidgetsReordered;

  const CustomizableDashboardWidget({
    Key? key,
    required this.availableWidgets,
    required this.activeWidgets,
    this.onWidgetsReordered,
  }) : super(key: key);

  @override
  State<CustomizableDashboardWidget> createState() => _CustomizableDashboardWidgetState();
}

class _CustomizableDashboardWidgetState extends State<CustomizableDashboardWidget> {
  late List<String> _activeWidgets;

  @override
  void initState() {
    super.initState();
    _activeWidgets = List.from(widget.activeWidgets);
  }

  @override
  void didUpdateWidget(CustomizableDashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeWidgets != widget.activeWidgets) {
      _activeWidgets = List.from(widget.activeWidgets);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _activeWidgets.removeAt(oldIndex);
      _activeWidgets.insert(newIndex, item);
    });
    widget.onWidgetsReordered?.call(_activeWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _activeWidgets.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final widgetId = _activeWidgets[index];
        final dashboardWidget = widget.availableWidgets.firstWhere(
          (w) => w.id == widgetId,
          orElse: () => throw Exception('Widget with id $widgetId not found'),
        );

        return Padding(
          key: ValueKey(dashboardWidget.id),
          padding: EdgeInsets.only(bottom: 16),
          child: Modern3DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(dashboardWidget.icon),
                      SizedBox(width: 8),
                      Text(
                        dashboardWidget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (dashboardWidget.isRealTime) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Live',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          // Show widget options menu
                        },
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: dashboardWidget.content,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Advanced chart widgets
class AdvancedLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;

  const AdvancedLineChart({
    Key? key,
    required this.spots,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeatmapChart extends StatelessWidget {
  final List<List<double>> data;
  final List<String> xLabels;
  final List<String> yLabels;

  const HeatmapChart({
    Key? key,
    required this.data,
    required this.xLabels,
    required this.yLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: data[0].length,
          childAspectRatio: 1,
        ),
        itemCount: data.length * data[0].length,
        itemBuilder: (context, index) {
          final row = index ~/ data[0].length;
          final col = index % data[0].length;
          final value = data[row][col];
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(value),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                value.toStringAsFixed(2),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}

class GaugeChart extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;

  const GaugeChart({
    Key? key,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _GaugePainter(
          value: value,
          min: min,
          max: max,
          backgroundColor: Theme.of(context).colorScheme.surface,
          valueColor: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color backgroundColor;
  final Color valueColor;

  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    // Draw background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.8,
      math.pi * 1.6,
      false,
      bgPaint,
    );
    
    // Draw value arc
    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    final valueRatio = (value - min) / (max - min);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.8,
      math.pi * 1.6 * valueRatio,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => true;
} 