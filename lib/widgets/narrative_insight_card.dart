import 'package:flutter/material.dart';
import 'package:business_dashboard/theme/modern_theme.dart';
import 'package:business_dashboard/widgets/modern_glass_card.dart';

class NarrativeInsight {
  final String title;
  final String insight;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool? isPositive;

  NarrativeInsight({
    required this.title,
    required this.insight,
    required this.icon,
    required this.iconColor,
    this.trend,
    this.isPositive,
  });
}

class NarrativeInsightCard extends StatelessWidget {
  final NarrativeInsight insight;

  const NarrativeInsightCard({Key? key, required this.insight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight.icon,
                  color: insight.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insight.insight,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (insight.trend != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: insight.isPositive == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  insight.trend!,
                  style: TextStyle(
                    color: insight.isPositive == true ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 