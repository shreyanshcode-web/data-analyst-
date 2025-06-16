class InsightItem {
  final String title;
  final String description;

  InsightItem({required this.title, required this.description});
}

class AnalysisResult {
  final List<InsightItem> insights;
  final Map<String, dynamic> metrics;
  final List<String> keyMetrics;
  final List<String> recommendedCharts;
  final Map<String, dynamic>? schema;

  AnalysisResult({
    required this.insights,
    required this.metrics,
    required this.keyMetrics,
    required this.recommendedCharts,
    this.schema,
  });

  factory AnalysisResult.fromRawInsights(String rawText) {
    // TODO: Implement proper parsing logic
    return AnalysisResult(
      insights: [
        InsightItem(
          title: 'Sample Insight',
          description: rawText,
        ),
      ],
      metrics: {},
      keyMetrics: [],
      recommendedCharts: [],
      schema: null,
    );
  }
} 