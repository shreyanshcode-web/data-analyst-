import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollAnimatedElement {
  final AnimationController controller;
  final Widget child;
  final Offset startOffset;
  final Curve curve;

  ScrollAnimatedElement({
    required this.controller,
    required this.child,
    required this.startOffset,
    this.curve = Curves.easeInOut,
  });
}

class ScrollAnimatedBackground extends StatefulWidget {
  final bool isDarkMode;

  const ScrollAnimatedBackground({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ScrollAnimatedBackground> createState() => _ScrollAnimatedBackgroundState();
}

class _ScrollAnimatedBackgroundState extends State<ScrollAnimatedBackground>
    with TickerProviderStateMixin {
  late List<ScrollAnimatedElement> elements;
  double scrollOffset = 0;
  final _key = GlobalKey();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeAnimations();
      _initialized = true;
    }
  }

  void _initializeAnimations() {
    final size = MediaQuery.of(context).size;
    elements = [
      // First wave of elements - Gradient waves
      ScrollAnimatedElement(
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1200),
        ),
        child: _buildWaveElement(
          color: widget.isDarkMode 
            ? Colors.blue.shade900.withOpacity(0.4) 
            : Colors.blue.shade200.withOpacity(0.3),
          height: 300,
          frequency: 0.015,
          phase: 0,
        ),
        startOffset: const Offset(-150, 0),
        curve: Curves.easeInOutCubic,
      ),
      ScrollAnimatedElement(
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1400),
        ),
        child: _buildWaveElement(
          color: widget.isDarkMode 
            ? Colors.purple.shade900.withOpacity(0.3) 
            : Colors.purple.shade200.withOpacity(0.2),
          height: 250,
          frequency: 0.02,
          phase: math.pi / 4,
        ),
        startOffset: const Offset(150, 50),
        curve: Curves.easeInOutQuad,
      ),
      // Second wave of elements - Floating shapes
      ScrollAnimatedElement(
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1600),
        ),
        child: _buildFloatingShapes(
          count: 5,
          size: size,
          color: widget.isDarkMode 
            ? Colors.indigo.withOpacity(0.3) 
            : Colors.indigo.shade200.withOpacity(0.2),
        ),
        startOffset: const Offset(0, -100),
        curve: Curves.easeOutBack,
      ),
      ScrollAnimatedElement(
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1800),
        ),
        child: _buildFloatingShapes(
          count: 3,
          size: size,
          color: widget.isDarkMode 
            ? Colors.teal.withOpacity(0.2) 
            : Colors.teal.shade200.withOpacity(0.15),
          shapeSize: 60,
        ),
        startOffset: const Offset(-50, 50),
        curve: Curves.elasticOut,
      ),
    ];
    _startAnimations();
  }

  void _startAnimations() {
    for (var element in elements) {
      element.controller.forward();
    }
  }

  Widget _buildWaveElement({
    required Color color,
    required double height,
    required double frequency,
    required double phase,
  }) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, height),
      painter: WavePainter(
        color: color,
        frequency: frequency,
        phase: phase,
      ),
    );
  }

  Widget _buildFloatingShapes({
    required int count,
    required Color color,
    required Size size,
    double shapeSize = 40,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: List.generate(count, (index) {
          final random = math.Random(index);
          final x = random.nextDouble() * size.width;
          final y = random.nextDouble() * size.height;
          final shape = random.nextBool()
              ? _buildCircle(shapeSize, color)
              : _buildSquare(shapeSize, color);

          return Positioned(
            left: x,
            top: y,
            child: shape,
          );
        }),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildSquare(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color,
      ),
    );
  }

  @override
  void dispose() {
    if (_initialized) {
      for (var element in elements) {
        element.controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 10) {
          for (var element in elements) {
            element.controller.forward();
          }
        }
      },
      child: SizedBox(
        height: 600,
        width: double.infinity,
        child: Stack(
          children: elements.map((element) {
            return AnimatedBuilder(
              animation: element.controller,
              builder: (context, child) {
                final value = element.curve.transform(element.controller.value);
                final opacity = value.clamp(0.0, 1.0);
                final offset = Offset.lerp(
                  element.startOffset,
                  Offset.zero,
                  value,
                )!;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: offset,
                    child: child,
                  ),
                );
              },
              child: element.child,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final double frequency;
  final double phase;

  WavePainter({
    required this.color,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x * frequency) + phase) * (size.height / 4);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 