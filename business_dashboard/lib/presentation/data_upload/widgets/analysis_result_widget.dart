import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:business_dashboard/core/models/insight_item.dart';
import 'package:business_dashboard/theme/flutterflow_theme.dart';
import 'package:business_dashboard/widgets/flutterflow/modern_3d_card.dart';

import '../../../core/app_export.dart';
import '../../../core/models/analysis_result.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AnalysisResultWidget extends StatefulWidget {
  final List<InsightItem> insights;

  const AnalysisResultWidget({
    Key? key,
    required this.insights,
  }) : super(key: key);

  @override
  State<AnalysisResultWidget> createState() => _AnalysisResultWidgetState();
}

class _AnalysisResultWidgetState extends State<AnalysisResultWidget> {
  @override
  Widget build(BuildContext context) {
    return FlutterFlowModern3DCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Results',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...widget.insights.map((insight) => _buildInsightCard(context, insight)).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightItem insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}