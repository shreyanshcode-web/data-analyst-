import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:business_dashboard/theme/flutterflow_theme.dart';
import 'package:business_dashboard/widgets/flutterflow/modern_3d_card.dart';

class FlutterFlowDashboardOverview extends StatefulWidget {
  const FlutterFlowDashboardOverview({Key? key}) : super(key: key);

  @override
  State<FlutterFlowDashboardOverview> createState() => _FlutterFlowDashboardOverviewState();
}

class _FlutterFlowDashboardOverviewState extends State<FlutterFlowDashboardOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Modern3DCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_money, 
                              color: Colors.green[400],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Total Revenue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$125,000',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Modern3DCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people,
                              color: Colors.blue[400],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Total Users',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1,234',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Modern3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 3),
                              const FlSpot(1, 3.5),
                              const FlSpot(2, 4.2),
                              const FlSpot(3, 4),
                              const FlSpot(4, 4.8),
                              const FlSpot(5, 4.5),
                              const FlSpot(6, 4.3),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Modern3DCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Growth',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8)]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10)]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 9)]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 11)]),
                                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 7)]),
                                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 12)]),
                                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 8)]),
                              ],
                              barTouchData: BarTouchData(enabled: false),
                              alignment: BarChartAlignment.spaceAround,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Modern3DCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sales Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: 35,
                                  color: Colors.blue,
                                  title: '35%',
                                  radius: 80,
                                ),
                                PieChartSectionData(
                                  value: 35,
                                  color: Colors.orange,
                                  title: '35%',
                                  radius: 80,
                                ),
                                PieChartSectionData(
                                  value: 30,
                                  color: Colors.green,
                                  title: '30%',
                                  radius: 80,
                                ),
                              ],
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 