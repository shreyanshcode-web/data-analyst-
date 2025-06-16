import 'package:flutter/material.dart';
import 'package:business_dashboard/core/app_export.dart';
import 'package:business_dashboard/core/services/real_time_data_service.dart';
import 'package:business_dashboard/core/services/performance_monitoring_service.dart';
import 'package:business_dashboard/core/services/predictive_analytics_service.dart';
import 'package:business_dashboard/widgets/custom_loading_indicator.dart';
import 'package:business_dashboard/widgets/modern_3d_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class DashboardOverviewScreen extends StatefulWidget {
  const DashboardOverviewScreen({Key? key}) : super(key: key);

  @override
  State<DashboardOverviewScreen> createState() => _DashboardOverviewScreenState();
}

class _DashboardOverviewScreenState extends State<DashboardOverviewScreen> {
  final _realTimeService = RealTimeDataService();
  final _performanceService = PerformanceMonitoringService();
  final _predictiveService = PredictiveAnalyticsService();
  int _selectedTimeRange = 7; // Default to 7 days

  @override
  void initState() {
    super.initState();
    _realTimeService.startRealTimeUpdates();
    _performanceService.startMonitoring();
    _predictiveService.startPredictions();
  }

  @override
  void dispose() {
    _realTimeService.dispose();
    _performanceService.dispose();
    _predictiveService.dispose();
    super.dispose();
  }

  void _navigateToDataUpload() {
    Navigator.pushNamed(context, '/data-upload');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Business Dashboard'),
        actions: [
          // Add Upload Data Button
          TextButton.icon(
            onPressed: _navigateToDataUpload,
            icon: Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
            label: Text('Upload Data', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        context,
                        'Total Revenue',
                        '\$124,500',
                        Icons.attach_money,
                        Colors.green,
                        '+12.5%',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickStatCard(
                        context,
                        'Active Users',
                        '1,234',
                        Icons.people,
                        Colors.blue,
                        '+5.2%',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickStatCard(
                        context,
                        'Conversion Rate',
                        '3.2%',
                        Icons.trending_up,
                        Colors.purple,
                        '+0.8%',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Revenue Chart Section
                Modern3DCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Revenue Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            _buildTimeRangeSelector(),
                          ],
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            _revenueData(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Performance Metrics and User Activity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Performance Metrics
                    Expanded(
                      flex: 3,
                      child: Modern3DCard(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'System Performance',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<PerformanceMetrics>(
                                stream: _performanceService.metricsStream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return CustomLoadingIndicator();
                                  }

                                  final metrics = snapshot.data!;
                                  return Column(
                                    children: [
                                      _buildPerformanceChart(metrics),
                                      SizedBox(height: 16),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 1.5,
                                        children: [
                                          _buildMetricCard(
                                            context,
                                            'CPU Usage',
                                            metrics.cpu,
                                            Colors.blue,
                                            isDarkMode,
                                          ),
                                          _buildMetricCard(
                                            context,
                                            'Memory Usage',
                                            metrics.memory,
                                            Colors.purple,
                                            isDarkMode,
                                          ),
                                          _buildMetricCard(
                                            context,
                                            'Disk Usage',
                                            metrics.disk,
                                            Colors.orange,
                                            isDarkMode,
                                          ),
                                          _buildMetricCard(
                                            context,
                                            'Network',
                                            metrics.network,
                                            Colors.green,
                                            isDarkMode,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // User Activity
                    Expanded(
                      flex: 2,
                      child: Modern3DCard(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Users',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _realTimeService.usersStream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return CustomLoadingIndicator();
                                  }

                                  final users = snapshot.data!;
                                  final onlineUsers = users.where((u) => u['status'] == 'online').length;

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildUserStat('Online Now', onlineUsers),
                                          _buildUserStat('Total Users', users.length),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      _buildUserActivityChart(users),
                                      SizedBox(height: 16),
                                      Expanded(
                                        child: SizedBox(
                                          height: 200,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: math.min(users.length, 5),
                                            itemBuilder: (context, index) {
                                              final user = users[index];
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                                  child: Text(user['name'][0]),
                                                ),
                                                title: Text(user['name']),
                                                subtitle: Text(user['lastActivity']),
                                                trailing: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: user['status'] == 'online'
                                                        ? Colors.green
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Predictive Analytics Section
                Modern3DCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Predictive Analytics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _predictiveService.getAnomalyDetection(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CustomLoadingIndicator();
                            }

                            final data = snapshot.data!;
                            final anomalies = data['anomalies'] as List;
                            final riskLevel = data['risk_level'] as String;
                            final details = data['details'] as Map<String, dynamic>;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Risk Level',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getRiskLevelColor(riskLevel).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            riskLevel.toUpperCase(),
                                            style: TextStyle(
                                              color: _getRiskLevelColor(riskLevel),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (details.containsKey('mean'))
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Anomaly Score',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            '${(details['mean'] as double).toStringAsFixed(2)}',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                if (details.containsKey('message')) ...[
                                  SizedBox(height: 16),
                                  Text(
                                    details['message'] as String,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                                if (anomalies.isNotEmpty) ...[
                                  SizedBox(height: 24),
                                  Text(
                                    'Recent Anomalies',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: _buildAnomalyChart(anomalies),
                                  ),
                                  SizedBox(height: 16),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: math.min(anomalies.length, 3),
                                    itemBuilder: (context, index) {
                                      final anomaly = anomalies[index] as Map<String, dynamic>;
                                      return ListTile(
                                        leading: Icon(
                                          Icons.warning,
                                          color: Colors.orange,
                                        ),
                                        title: Text(
                                          'Anomaly at ${anomaly['timestamp']}',
                                        ),
                                        subtitle: Text(
                                          'Value: ${anomaly['value'].toStringAsFixed(2)}, '
                                          'Z-Score: ${anomaly['z_score'].toStringAsFixed(2)}',
                                        ),
                                      );
                                    },
                                  ),
                                ] else
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        'No anomalies detected',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // AI Insights & Recommendations
                Modern3DCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.blue,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AI Insights & Recommendations',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Growth Opportunities
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Growth Opportunities',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 16),
                                  _buildAIPredictionCard(
                                    context,
                                    'Market Expansion',
                                    'High potential for market growth in Southeast Asia region',
                                    '89%',
                                    Colors.green,
                                    [
                                      'Target Singapore and Malaysia first',
                                      'Focus on electronics and fashion categories',
                                      'Estimated 3-month ROI: 2.5x',
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildAIPredictionCard(
                                    context,
                                    'Product Line Extension',
                                    'Add smart home devices to your catalog',
                                    '76%',
                                    Colors.blue,
                                    [
                                      'High demand predicted in Q3',
                                      'Partner with leading IoT manufacturers',
                                      'Expected margin: 45-50%',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 24),
                            // Risk Mitigation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Risk Mitigation',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 16),
                                  _buildAIPredictionCard(
                                    context,
                                    'Inventory Optimization',
                                    'Current stock levels need adjustment',
                                    '92%',
                                    Colors.orange,
                                    [
                                      'Reduce smartphone inventory by 15%',
                                      'Increase laptop stock by 25%',
                                      'Implement automated reordering',
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildAIPredictionCard(
                                    context,
                                    'Customer Churn Prevention',
                                    'Risk of losing premium customers',
                                    '67%',
                                    Colors.red,
                                    [
                                      'Launch loyalty program upgrade',
                                      'Personalize communication',
                                      'Offer exclusive early access',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Predictive Trends
                        Text(
                          'Predictive Trends',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Row(
                            children: [
                              // Sales Forecast
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sales Forecast (Next 6 Months)',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(show: true),
                                          titlesData: FlTitlesData(
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          ),
                                          borderData: FlBorderData(show: true),
                                          lineBarsData: [
                                            // Historical Data
                                            LineChartBarData(
                                              spots: [
                                                FlSpot(0, 100),
                                                FlSpot(1, 120),
                                                FlSpot(2, 110),
                                                FlSpot(3, 130),
                                                FlSpot(4, 140),
                                                FlSpot(5, 135),
                                              ],
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 3,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: true),
                                            ),
                                            // Predicted Data
                                            LineChartBarData(
                                              spots: [
                                                FlSpot(5, 135),
                                                FlSpot(6, 150),
                                                FlSpot(7, 170),
                                                FlSpot(8, 190),
                                                FlSpot(9, 210),
                                                FlSpot(10, 230),
                                              ],
                                              isCurved: true,
                                              color: Colors.green,
                                              barWidth: 2,
                                              isStrokeCapRound: true,
                                              dotData: FlDotData(show: true),
                                              dashArray: [5, 5],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24),
                              // Market Sentiment
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Market Sentiment Analysis',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    SizedBox(height: 16),
                                    _buildSentimentCard(
                                      context,
                                      'Product Quality',
                                      0.85,
                                      Colors.green,
                                      'Strong positive sentiment',
                                    ),
                                    SizedBox(height: 12),
                                    _buildSentimentCard(
                                      context,
                                      'Customer Service',
                                      0.72,
                                      Colors.blue,
                                      'Generally positive',
                                    ),
                                    SizedBox(height: 12),
                                    _buildSentimentCard(
                                      context,
                                      'Price Competitiveness',
                                      0.65,
                                      Colors.orange,
                                      'Mixed sentiment',
                                    ),
                                    SizedBox(height: 12),
                                    _buildSentimentCard(
                                      context,
                                      'Delivery Speed',
                                      0.78,
                                      Colors.green,
                                      'Improving trend',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Action Items
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommended Actions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildActionChip(
                                    context,
                                    'Launch Customer Loyalty Program 2.0',
                                    Icons.loyalty,
                                    Colors.purple,
                                  ),
                                  _buildActionChip(
                                    context,
                                    'Optimize Inventory Levels',
                                    Icons.inventory_2,
                                    Colors.blue,
                                  ),
                                  _buildActionChip(
                                    context,
                                    'Expand to Southeast Asia',
                                    Icons.public,
                                    Colors.green,
                                  ),
                                  _buildActionChip(
                                    context,
                                    'Implement AI Chatbot',
                                    Icons.smart_toy,
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Data Analysis Section
                Modern3DCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Analysis & Insights',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildKPICard(
                                context,
                                'Customer Retention',
                                '87%',
                                Icons.people_outline,
                                Colors.blue,
                                '+5.2%',
                                'Monthly retention rate has improved',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildKPICard(
                                context,
                                'Average Order Value',
                                '\$156',
                                Icons.shopping_cart_outlined,
                                Colors.green,
                                '+12.3%',
                                'Higher than last month',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildKPICard(
                                context,
                                'Customer Satisfaction',
                                '4.8/5',
                                Icons.star_outline,
                                Colors.amber,
                                '+0.3',
                                'Based on 1,234 reviews',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sales Distribution Chart
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sales Distribution by Category',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 300,
                                    child: PieChart(
                                      PieChartData(
                                        sections: [
                                          PieChartSectionData(
                                            value: 35,
                                            title: 'Electronics',
                                            color: Colors.blue,
                                            radius: 100,
                                          ),
                                          PieChartSectionData(
                                            value: 25,
                                            title: 'Fashion',
                                            color: Colors.green,
                                            radius: 100,
                                          ),
                                          PieChartSectionData(
                                            value: 20,
                                            title: 'Home',
                                            color: Colors.orange,
                                            radius: 100,
                                          ),
                                          PieChartSectionData(
                                            value: 20,
                                            title: 'Others',
                                            color: Colors.purple,
                                            radius: 100,
                                          ),
                                        ],
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 24),
                            // Key Insights
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Key Insights',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 16),
                                  _buildInsightCard(
                                    context,
                                    'Peak Shopping Hours',
                                    'Most purchases occur between 6 PM and 9 PM',
                                    Icons.access_time,
                                    Colors.blue,
                                  ),
                                  SizedBox(height: 12),
                                  _buildInsightCard(
                                    context,
                                    'Popular Products',
                                    'Top 3: Smartphones, Laptops, Smart Watches',
                                    Icons.trending_up,
                                    Colors.green,
                                  ),
                                  SizedBox(height: 12),
                                  _buildInsightCard(
                                    context,
                                    'Customer Behavior',
                                    '65% of customers return within 30 days',
                                    Icons.people,
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Customer Segmentation
                Modern3DCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Segmentation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSegmentCard(
                                context,
                                'New Customers',
                                '324',
                                '+12%',
                                Colors.blue,
                                'Last 30 days',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildSegmentCard(
                                context,
                                'Regular Customers',
                                '1,567',
                                '+5%',
                                Colors.green,
                                '2-12 purchases',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildSegmentCard(
                                context,
                                'VIP Customers',
                                '243',
                                '+8%',
                                Colors.purple,
                                '12+ purchases',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Customer Lifetime Value',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 100),
                                    FlSpot(1, 125),
                                    FlSpot(2, 180),
                                    FlSpot(3, 220),
                                    FlSpot(4, 280),
                                    FlSpot(5, 310),
                                  ],
                                  isCurved: true,
                                  color: Colors.purple,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.purple.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Modern3DCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              change,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<int>(
      segments: [
        ButtonSegment<int>(value: 7, label: Text('7D')),
        ButtonSegment<int>(value: 30, label: Text('30D')),
        ButtonSegment<int>(value: 90, label: Text('90D')),
      ],
      selected: {_selectedTimeRange},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedTimeRange = newSelection.first;
        });
      },
    );
  }

  LineChartData _revenueData() {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            _selectedTimeRange,
            (index) => FlSpot(
              index.toDouble(),
              math.sin(index * 0.1) * 50 + 100 + math.Random().nextDouble() * 20,
            ),
          ),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(PerformanceMetrics metrics) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, metrics.cpu),
                FlSpot(1, metrics.memory),
                FlSpot(2, metrics.disk),
                FlSpot(3, metrics.network),
              ],
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.purple.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityChart(List<Map<String, dynamic>> users) {
    final onlineUsers = users.where((u) => u['status'] == 'online').length;
    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: onlineUsers.toDouble(),
              title: 'Online',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.grey,
              value: (users.length - onlineUsers).toDouble(),
              title: 'Offline',
              radius: 45,
              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          sectionsSpace: 0,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildAnomalyChart(List<dynamic> anomalies) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: anomalies.asMap().entries.map((entry) {
              final anomaly = entry.value as Map<String, dynamic>;
              return FlSpot(
                entry.key.toDouble(),
                anomaly['value'].toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    double value,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Expanded(
            child: Center(
              child: Text(
                '${value.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                    ),
              ),
            ),
          ),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildKPICard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    String description,
  ) {
    return Modern3DCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  change,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Modern3DCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentCard(
    BuildContext context,
    String title,
    String value,
    String change,
    Color color,
    String description,
  ) {
    return Modern3DCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  change,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPredictionCard(
    BuildContext context,
    String title,
    String description,
    String confidence,
    Color color,
    List<String> recommendations,
  ) {
    return Modern3DCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confidence: $confidence',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, size: 20, color: color),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentCard(
    BuildContext context,
    String title,
    double sentiment,
    Color color,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(sentiment * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: sentiment,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return ActionChip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      onPressed: () {
        // TODO: Implement action
      },
    );
  }
} 