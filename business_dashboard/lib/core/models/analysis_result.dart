/// Represents the results of a data analysis 
class AnalysisResult {
  final String summary;
  final List<String> insights;
  final Map<String, dynamic>? statistics;
  final List<Map<String, dynamic>>? chartData;
  final List<Map<String, dynamic>> keyMetrics;
  final List<Map<String, dynamic>> recommendedCharts;
  final List<AnalysisInsight> analysisInsights;
  final DateTime timestamp;

  AnalysisResult({
    required this.summary,
    required this.insights,
    this.statistics,
    this.chartData,
    this.keyMetrics = const [],
    this.recommendedCharts = const [],
    required this.analysisInsights,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory method to parse raw insights text into structured data
  factory AnalysisResult.fromRawInsights(String rawText) {
    // Parse raw text into insights
    final insights = rawText.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            return InsightItem(
              title: parts[0].trim(),
              description: parts.sublist(1).join(':').trim(),
            );
          }
          return null;
        })
        .whereType<InsightItem>()
        .toList();

    return AnalysisResult(analysisInsights: insights);
  }

  /// Create a copy of this result with some fields updated
  AnalysisResult copyWith({
    String? summary,
    List<String>? insights,
    Map<String, dynamic>? statistics,
    List<Map<String, dynamic>>? chartData,
    List<Map<String, dynamic>>? keyMetrics,
    List<Map<String, dynamic>>? recommendedCharts,
    List<AnalysisInsight>? analysisInsights,
    DateTime? timestamp,
  }) {
    return AnalysisResult(
      summary: summary ?? this.summary,
      insights: insights ?? this.insights,
      statistics: statistics ?? this.statistics,
      chartData: chartData ?? this.chartData,
      keyMetrics: keyMetrics ?? this.keyMetrics,
      recommendedCharts: recommendedCharts ?? this.recommendedCharts,
      analysisInsights: analysisInsights ?? this.analysisInsights,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      summary: json['summary'],
      insights: (json['insights'] as List).map((i) => i['description'] as String).toList(),
      statistics: json['statistics'],
      chartData: json['chartData'] as List<Map<String, dynamic>>?,
      keyMetrics: (json['keyMetrics'] as List).map((m) => m as Map<String, dynamic>).toList(),
      recommendedCharts: (json['recommendedCharts'] as List).map((c) => c as Map<String, dynamic>).toList(),
      analysisInsights: (json['analysisInsights'] as List).map((i) => AnalysisInsight.fromJson(i)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'insights': insights,
      'statistics': statistics,
      'chartData': chartData,
      'keyMetrics': keyMetrics,
      'recommendedCharts': recommendedCharts,
      'analysisInsights': analysisInsights.map((i) => i.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents a single insight extracted from the analysis
class AnalysisInsight {
  final String title;
  final String description;
  final Map<String, dynamic>? data;

  AnalysisInsight({
    required this.title,
    required this.description,
    this.data,
  });

  factory AnalysisInsight.fromJson(Map<String, dynamic> json) {
    return AnalysisInsight(
      title: json['title'],
      description: json['description'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'data': data,
    };
  }
}

/// Types of insights
enum InsightType { general, trend, anomaly, recommendation }

class InsightItem {
  final String title;
  final String description;

  InsightItem({
    required this.title,
    required this.description,
  });
}
