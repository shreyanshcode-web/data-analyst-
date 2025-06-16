import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Modern3DCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const Modern3DCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.elevation = 8.0,
    this.borderRadius,
    this.padding,
    this.showBorder = true,
    this.onTap,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          gradient: gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, elevation / 2),
              blurRadius: elevation,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, elevation / 4),
              blurRadius: elevation / 2,
            ),
          ],
          border: showBorder
              ? Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
} 