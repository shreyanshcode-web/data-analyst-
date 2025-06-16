import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/metric_chart_widget.dart';
import './widgets/metric_data_table_widget.dart';
import 'widgets/metric_chart_widget.dart';
import 'widgets/metric_data_table_widget.dart';

class DetailedMetricView extends StatefulWidget {
  const DetailedMetricView({Key? key}) : super(key: key);

  @override
  State<DetailedMetricView> createState() => _DetailedMetricViewState();
}

class _DetailedMetricViewState extends State<DetailedMetricView> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _metricData;
  bool _isLineChart = true;
  
  @override
  void initState() {
    super.initState();
    _loadMetricData();
  }

  Future<void> _loadMetricData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 3));
      
      // Mock data loading
      setState(() {
        _metricData = mockMetricData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load metric data. Please try again.';
      });
    }
  }

  void _toggleChartType() {
    setState(() {
      _isLineChart = !_isLineChart;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _metricData?['title'] ?? 'Metric Details',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: const CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard-overview'),
          tooltip: 'Back to Dashboard',
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isLineChart ? 'bar_chart' : 'show_chart',
              color: AppTheme.primary,
              size: 24,
            ),
            onPressed: _toggleChartType,
            tooltip: _isLineChart ? 'Switch to Bar Chart' : 'Switch to Line Chart',
          ),
          IconButton(
            icon: const CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.textPrimary,
              size: 24,
            ),
            onPressed: () {
              // Show options menu
              _showOptionsMenu(context);
            },
            tooltip: 'More Options',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading metric data...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: _loadMetricData,
              icon: const CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMetricData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricHeader(),
              SizedBox(height: 2.h),
              MetricChartWidget(
                chartData: _metricData!['chartData'] as List<Map<String, dynamic>>,
                isLineChart: _isLineChart,
              ),
              SizedBox(height: 3.h),
              _buildMetricInsights(),
              SizedBox(height: 3.h),
              Text(
                'Detailed Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 1.h),
              MetricDataTableWidget(
                tableData: _metricData!['tableData'] as List<Map<String, dynamic>>,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(_metricData?['category']).withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _metricData?['category'] ?? 'Category',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _getCategoryColor(_metricData?['category']),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Last updated: ${_metricData?['lastUpdated'] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          _metricData?['description'] ?? 'No description available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMetricInsights() {
    final insights = _metricData?['insights'] as List<Map<String, dynamic>>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 1.h),
        insights.isEmpty
            ? Text(
                'No insights available for this metric.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : Column(
                children: insights.map((insight) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconWidget(
                            iconName: insight['icon'] as String? ?? 'lightbulb',
                            color: _getInsightColor(insight['type'] as String?),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight['title'] as String? ?? 'Insight',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  insight['description'] as String? ?? 'No description',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
                title: const Text('Export Data'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting data...')),
                  );
                },
              ),
              ListTile(
                leading: const CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
                title: const Text('Share Metric'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing metric...')),
                  );
                },
              ),
              ListTile(
                leading: const CustomIconWidget(
                  iconName: 'filter_alt',
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
                title: const Text('Configure Filters'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to filter configuration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter configuration would be implemented here')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Sales':
        return AppTheme.primary;
      case 'Revenue':
        return AppTheme.success;
      case 'Customers':
        return AppTheme.info;
      case 'Performance':
        return AppTheme.chart1;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getInsightColor(String? type) {
    switch (type) {
      case 'positive':
        return AppTheme.success;
      case 'negative':
        return AppTheme.error;
      case 'neutral':
        return AppTheme.info;
      case 'warning':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }
}

// Mock data for the metric
final Map<String, dynamic> mockMetricData = {
  "id": "sales-performance-q2",
  "title": "Sales Performance Q2",
  "description": "Quarterly sales performance metrics showing revenue trends, conversion rates, and regional distribution for Q2 2023.",
  "category": "Sales",
  "lastUpdated": "July 15, 2023",
  "chartData": [
    {"date": "Apr 1", "value": 42000, "target": 40000},
    {"date": "Apr 8", "value": 45000, "target": 42000},
    {"date": "Apr 15", "value": 48000, "target": 44000},
    {"date": "Apr 22", "value": 46000, "target": 46000},
    {"date": "Apr 29", "value": 49000, "target": 48000},
    {"date": "May 6", "value": 52000, "target": 50000},
    {"date": "May 13", "value": 55000, "target": 52000},
    {"date": "May 20", "value": 59000, "target": 54000},
    {"date": "May 27", "value": 62000, "target": 56000},
    {"date": "Jun 3", "value": 58000, "target": 58000},
    {"date": "Jun 10", "value": 56000, "target": 60000},
    {"date": "Jun 17", "value": 61000, "target": 62000},
    {"date": "Jun 24", "value": 65000, "target": 64000},
  ],
  "tableData": [
    {"date": "Apr 1, 2023", "revenue": "\$42,000", "orders": 156, "avgOrderValue": "\$269.23", "conversionRate": "3.2%"},
    {"date": "Apr 8, 2023", "revenue": "\$45,000", "orders": 167, "avgOrderValue": "\$269.46", "conversionRate": "3.4%"},
    {"date": "Apr 15, 2023", "revenue": "\$48,000", "orders": 178, "avgOrderValue": "\$269.66", "conversionRate": "3.5%"},
    {"date": "Apr 22, 2023", "revenue": "\$46,000", "orders": 170, "avgOrderValue": "\$270.59", "conversionRate": "3.3%"},
    {"date": "Apr 29, 2023", "revenue": "\$49,000", "orders": 181, "avgOrderValue": "\$270.72", "conversionRate": "3.6%"},
    {"date": "May 6, 2023", "revenue": "\$52,000", "orders": 192, "avgOrderValue": "\$270.83", "conversionRate": "3.7%"},
    {"date": "May 13, 2023", "revenue": "\$55,000", "orders": 203, "avgOrderValue": "\$270.94", "conversionRate": "3.9%"},
    {"date": "May 20, 2023", "revenue": "\$59,000", "orders": 218, "avgOrderValue": "\$270.64", "conversionRate": "4.1%"},
    {"date": "May 27, 2023", "revenue": "\$62,000", "orders": 229, "avgOrderValue": "\$270.74", "conversionRate": "4.3%"},
    {"date": "Jun 3, 2023", "revenue": "\$58,000", "orders": 214, "avgOrderValue": "\$271.03", "conversionRate": "4.0%"},
    {"date": "Jun 10, 2023", "revenue": "\$56,000", "orders": 207, "avgOrderValue": "\$270.53", "conversionRate": "3.8%"},
    {"date": "Jun 17, 2023", "revenue": "\$61,000", "orders": 225, "avgOrderValue": "\$271.11", "conversionRate": "4.2%"},
    {"date": "Jun 24, 2023", "revenue": "\$65,000", "orders": 240, "avgOrderValue": "\$270.83", "conversionRate": "4.5%"},
  ],
  "insights": [
    {
      "title": "Exceeded Q2 Target",
      "description": "Sales exceeded the quarterly target by 7.8%, with particularly strong performance in May.",
      "type": "positive",
      "icon": "trending_up"
    },
    {
      "title": "Conversion Rate Improvement",
      "description": "Conversion rate increased from 3.2% to 4.5% over the quarter, indicating improved marketing effectiveness.",
      "type": "positive",
      "icon": "swap_vert"
    },
    {
      "title": "June 10 Dip",
      "description": "Sales dipped below target on June 10, possibly due to the website maintenance scheduled that weekend.",
      "type": "warning",
      "icon": "warning"
    }
  ]
};