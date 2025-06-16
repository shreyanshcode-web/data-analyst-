import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({Key? key}) : super(key: key);

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.5, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildSkeletonRect(
                  width: 120,
                  height: 20,
                  opacity: _animation.value,
                  isDarkMode: isDarkMode,
                );
              },
            ),
            SizedBox(height: 16),
            
            // Value skeleton
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildSkeletonRect(
                  width: 100,
                  height: 32,
                  opacity: _animation.value,
                  isDarkMode: isDarkMode,
                );
              },
            ),
            SizedBox(height: 16),
            
            // Chart skeleton
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return _buildSkeletonChart(
                    opacity: _animation.value,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonRect({
    required double width,
    required double height,
    required double opacity,
    required bool isDarkMode,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.borderDark.withOpacity(opacity)
            : AppTheme.border.withOpacity(opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonChart({
    required double opacity,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.borderDark.withOpacity(opacity * 0.7)
            : AppTheme.border.withOpacity(opacity * 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}