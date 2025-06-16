import 'package:flutter/material.dart';
import '../../core/models/analysis_result.dart';
import '../../core/services/gemini_service.dart';
import '../../widgets/flutterflow/modern_3d_card.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({Key? key}) : super(key: key);

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  late GeminiService _geminiService;
  List<InsightItem> _insights = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    try {
      _geminiService = GeminiService();
      await _generateInsights();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _generateInsights() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Sample data for demonstration
      const sampleData = '''
Revenue by Month:
January: $45,000
February: $52,000
March: $48,000
April: $55,000
May: $60,000
June: $58,000

Customer Acquisition:
Q1: 150 new customers
Q2: 180 new customers
Retention Rate: 85%

Product Performance:
Product A: 45% of sales
Product B: 30% of sales
Product C: 25% of sales
''';

      final result = await _geminiService.analyzeData(
        prompt: 'Analyze this business performance data',
        data: sampleData,
      );

      setState(() {
        _insights = result.analysisInsights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate insights: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateInsights,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating insights...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateInsights,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insights.length,
      itemBuilder: (context, index) {
        final insight = _insights[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Modern3DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 