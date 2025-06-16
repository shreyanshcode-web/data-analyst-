import 'package:flutter/material.dart';
import 'modern_3d_background.dart';
import 'modern_3d_card.dart';

class Modern3DScreen extends StatelessWidget {
  final Widget child;
  final bool enableParallax;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool showGradient;

  const Modern3DScreen({
    Key? key,
    required this.child,
    this.enableParallax = true,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.showGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Background with parallax effect
          Modern3DBackground(
            isDarkMode: isDarkMode,
            enableParallax: enableParallax,
          ),
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: showGradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      ],
                    )
                  : null,
              color: !showGradient ? backgroundColor ?? Theme.of(context).colorScheme.surface : null,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
} 