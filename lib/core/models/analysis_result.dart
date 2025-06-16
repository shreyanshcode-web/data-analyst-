class AnalysisResult {
  final List<AnalysisInsight> analysisInsights;
  final String summary;

  AnalysisResult({
    required this.analysisInsights,
    required this.summary,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      analysisInsights: (json['insights'] as List)
          .map((insight) => AnalysisInsight.fromJson(insight))
          .toList(),
      summary: json['summary'] as String,
    );
  }
}

class AnalysisInsight {
  final String title;
  final String description;
  final String trend;
  final bool isPositive;

  AnalysisInsight({
    required this.title,
    required this.description,
    required this.trend,
    required this.isPositive,
  });

  factory AnalysisInsight.fromJson(Map<String, dynamic> json) {
    return AnalysisInsight(
      title: json['title'] as String,
      description: json['description'] as String,
      trend: json['trend'] as String,
      isPositive: json['isPositive'] as bool,
    );
  }
} 