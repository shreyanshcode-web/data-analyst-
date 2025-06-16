import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/skeleton_card_widget.dart';
import 'widgets/date_range_selector_widget.dart';
import 'widgets/metric_card_widget.dart';
import 'widgets/skeleton_card_widget.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({Key? key}) : super(key: key);

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String selectedDateRange = 'Week';
  DateTime lastRefreshed = DateTime.now();
  late Future<void> _refreshFuture;

  // Mock data for metrics
  List<Map<String, dynamic>> metrics = [];

  @override
  void initState() {
    super.initState();
    _refreshFuture = _loadDashboardData();
    
    // Set up periodic refresh (every 5 minutes)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _setupPeriodicRefresh();
      }
    });
  }

  void _setupPeriodicRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _refreshDashboard();
        _setupPeriodicRefresh(); // Schedule next refresh
      }
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Simulate API call delay (max 2s as per requirements)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Mock API response
      final response = await _fetchDashboardMetrics(selectedDateRange);
      
      if (!mounted) return;
      
      setState(() {
        metrics = response;
        isLoading = false;
        lastRefreshed = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = 'Failed to load dashboard data. Please check your connection.';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDashboardMetrics(String dateRange) async {
    // This would be a real API call in production
    // Simulating different data based on selected date range
    
    // Generate different mock data based on date range
    final multiplier = dateRange == 'Today' ? 0.8 : 
                       dateRange == 'Week' ? 1.0 : 
                       dateRange == 'Month' ? 1.2 : 1.5;
    
    return [
      {
        "id": "revenue",
        "name": "Total Revenue",
        "value": (125000 * multiplier).round(),
        "format": "currency",
        "changePercentage": 12.5 * (dateRange == 'Today' ? 0.7 : 1.0),
        "changeDirection": "up",
        "timeSeriesData": _generateTimeSeriesData(24, isUptrend: true, volatility: 0.05, multiplier: multiplier),
        "color": AppTheme.primary,
      },
      {
        "id": "customers",
        "name": "Active Customers",
        "value": (1250 * multiplier).round(),
        "format": "number",
        "changePercentage": 5.2 * (dateRange == 'Month' ? 1.2 : 1.0),
        "changeDirection": "up",
        "timeSeriesData": _generateTimeSeriesData(24, isUptrend: true, volatility: 0.03, multiplier: multiplier),
        "color": AppTheme.chart1,
      },
      {
        "id": "conversion",
        "name": "Conversion Rate",
        "value": 3.75 * (dateRange == 'Quarter' ? 1.1 : 1.0),
        "format": "percentage",
        "changePercentage": -1.8 * (dateRange == 'Today' ? 1.5 : 1.0),
        "changeDirection": "down",
        "timeSeriesData": _generateTimeSeriesData(24, isUptrend: false, volatility: 0.02, multiplier: multiplier),
        "color": AppTheme.chart2,
      },
      {
        "id": "aov",
        "name": "Average Order Value",
        "value": (85 * multiplier).round(),
        "format": "currency",
        "changePercentage": 7.3 * (dateRange == 'Week' ? 0.9 : 1.0),
        "changeDirection": "up",
        "timeSeriesData": _generateTimeSeriesData(24, isUptrend: true, volatility: 0.04, multiplier: multiplier),
        "color": AppTheme.chart3,
      },
    ];
  }

  List<FlSpot> _generateTimeSeriesData(int points, {
    required bool isUptrend, 
    double volatility = 0.05,
    double multiplier = 1.0,
  }) {
    final List<FlSpot> result = [];
    double value = 10.0 * multiplier;
    final trend = isUptrend ? 0.2 : -0.15;
    
    for (int i = 0; i < points; i++) {
      // Add some randomness to the trend
      final randomFactor = (Random().nextDouble() * 2 - 1) * volatility;
      value = value * (1 + trend * randomFactor);
      
      // Ensure value stays positive and within reasonable range
      value = value.clamp(5.0, 20.0) * multiplier;
      
      result.add(FlSpot(i.toDouble(), value));
    }
    
    return result;
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _refreshFuture = _loadDashboardData();
    });
  }

  void _onDateRangeChanged(String newRange) {
    if (selectedDateRange != newRange) {
      setState(() {
        selectedDateRange = newRange;
        _refreshFuture = _loadDashboardData();
      });
    }
  }

  void _navigateToDetailedView(String metricId) {
    // Navigate to detailed metric view
    Navigator.pushNamed(
      context, 
      '/detailed-metric-view',
      arguments: {
        'metricId': metricId,
        'dateRange': selectedDateRange,
      },
    );
  }

  void _openFilterConfiguration() {
    // Navigate to filter configuration
    Navigator.pushNamed(context, '/filter-configuration');
  }

  void _navigateToDataUpload() {
    // Navigate to data upload screen
    Navigator.pushNamed(context, '/data-upload');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _buildAppBar(theme, isDarkMode),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme),
                      SizedBox(height: 16),
                      DateRangeSelectorWidget(
                        selectedRange: selectedDateRange,
                        onRangeChanged: _onDateRangeChanged,
                      ),
                      SizedBox(height: 8),
                      _buildLastRefreshedText(theme),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildMetricsGrid(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _navigateToDataUpload,
            heroTag: 'dataUploadFab',
            tooltip: 'Upload Data',
            child: CustomIconWidget(
              iconName: 'upload_file',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _openFilterConfiguration,
            heroTag: 'filterFab',
            tooltip: 'Configure Filters',
            child: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme, bool isDarkMode) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.surfaceDark : AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'insights',
                color: isDarkMode ? AppTheme.primaryLight : Colors.white,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Business Dashboard',
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'account_circle',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            // User profile action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User profile would open here'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'notifications',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            // Notifications action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notifications would open here'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Monitor your key business metrics in real-time',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLastRefreshedText(ThemeData theme) {
    final formattedTime = '${lastRefreshed.hour.toString().padLeft(2, '0')}:${lastRefreshed.minute.toString().padLeft(2, '0')}';
    
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'update',
          color: theme.colorScheme.onSurfaceVariant,
          size: 14,
        ),
        SizedBox(width: 4),
        Text(
          'Last updated at $formattedTime',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Spacer(),
        TextButton.icon(
          onPressed: _refreshDashboard,
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: theme.colorScheme.primary,
            size: 16,
          ),
          label: Text('Refresh'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return FutureBuilder<void>(
      future: _refreshFuture,
      builder: (context, snapshot) {
        if (hasError) {
          return SliverFillRemaining(
            child: _buildErrorState(),
          );
        }
        
        if (isLoading) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => SkeletonCardWidget(),
                childCount: 4,
              ),
            ),
          );
        }
        
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final metric = metrics[index];
                return MetricCardWidget(
                  metric: metric,
                  onTap: () => _navigateToDetailedView(metric['id'] as String),
                );
              },
              childCount: metrics.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.error,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshDashboard,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}