import 'package:flutter/material.dart';
import '../../core/models/analysis_result.dart';
import '../../widgets/flutterflow/modern_3d_card.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({Key? key}) : super(key: key);

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  late List<AnalysisInsight> _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final result = AnalysisResult(
      analysisInsights: [
        AnalysisInsight(
          title: 'Revenue Growth',
          description: 'Monthly revenue has increased by 25% compared to last quarter',
          trend: '+25%',
          isPositive: true,
        ),
        AnalysisInsight(
          title: 'User Engagement',
          description: 'Daily active users have grown by 40% since new feature launch',
          trend: '+40%',
          isPositive: true,
        ),
        AnalysisInsight(
          title: 'Customer Retention',
          description: 'Customer churn rate decreased by 15% this month',
          trend: '-15%',
          isPositive: true,
        ),
      ],
      summary: 'Overall business performance shows positive growth trends.',
    );

    setState(() {
      _insights = result.analysisInsights;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Modern3DCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly Revenue Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'January: \$45,000\n'
                            'February: \$52,000\n'
                            'March: \$48,000\n'
                            'April: \$55,000\n'
                            'May: \$60,000\n'
                            'June: \$58,000',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Key Insights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _insights.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final insight = _insights[index];
                      return Modern3DCard(
                        child: ListTile(
                          title: Text(insight.title),
                          subtitle: Text(insight.description),
                          trailing: Text(
                            insight.trend,
                            style: TextStyle(
                              color: insight.isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
} 