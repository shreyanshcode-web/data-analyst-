class InsightItem {
  final String title;
  final String description;
  final Map<String, dynamic>? data;
  final InsightType type;

  InsightItem({
    required this.title,
    required this.description,
    this.data,
    this.type = InsightType.general,
  });

  factory InsightItem.fromJson(Map<String, dynamic> json) {
    return InsightItem(
      title: json['title'] as String,
      description: json['description'] as String,
      data: json['data'] as Map<String, dynamic>?,
      type: InsightType.values.firstWhere(
        (e) => e.toString() == 'InsightType.${json['type']}',
        orElse: () => InsightType.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'data': data,
      'type': type.toString().split('.').last,
    };
  }
}

enum InsightType {
  general,
  trend,
  anomaly,
  recommendation,
} 