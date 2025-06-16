import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double direction;

  AnimatedParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.direction,
  });

  factory AnimatedParticle.random(Size screenSize) {
    final random = math.Random();
    return AnimatedParticle(
      x: random.nextDouble() * screenSize.width,
      y: random.nextDouble() * screenSize.height,
      speed: 1 + random.nextDouble() * 2,
      size: 2 + random.nextDouble() * 4,
      opacity: 0.1 + random.nextDouble() * 0.4,
      direction: random.nextDouble() * 2 * math.pi,
    );
  }

  void update(Size screenSize) {
    y += speed;
    x += math.sin(direction) * speed / 2;

    if (y > screenSize.height) {
      y = -size;
      x = math.Random().nextDouble() * screenSize.width;
    }
    if (x < 0) {
      x = 0;
      direction = -direction;
    } else if (x > screenSize.width) {
      x = screenSize.width;
      direction = -direction;
    }
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  final List<AnimatedParticle> particles;
  final List<Color> gradientColors;
  final Size screenSize;

  AnimatedBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
    required this.particles,
    required this.gradientColors,
    required this.screenSize,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw gradient background
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment(
        math.cos(animation.value * 2 * math.pi) * 0.2 + 0.5,
        math.sin(animation.value * 2 * math.pi) * 0.2 + 0.5,
      ),
      end: Alignment(
        math.cos(animation.value * 2 * math.pi + math.pi) * 0.2 + 0.5,
        math.sin(animation.value * 2 * math.pi + math.pi) * 0.2 + 0.5,
      ),
      colors: gradientColors,
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw particles
    for (var particle in particles) {
      particle.update(screenSize);
      final particlePaint = Paint()
        ..color = gradientColors.last.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        particlePaint,
      );
    }

    // Draw waves
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = gradientColors.last.withOpacity(0.3);

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = size.height * 0.1;
      final frequency = 2 + i * 0.5;
      final horizontalOffset = animation.value * 100 + i * 60;

      path.moveTo(0, size.height * 0.5);
      for (var x = 0.0; x <= size.width; x++) {
        final y = math.sin((x - horizontalOffset) / 50 * frequency) * waveHeight +
            size.height * 0.5;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }

    // Draw glowing orbs
    final orbPaint = Paint()..style = PaintingStyle.fill;
    final numOrbs = 5;
    for (var i = 0; i < numOrbs; i++) {
      final progress = (animation.value + i / numOrbs) % 1.0;
      final orb = Offset(
        size.width * (0.2 + progress * 0.6),
        size.height * (0.3 + math.sin(progress * math.pi * 2) * 0.2),
      );

      final gradient = RadialGradient(
        colors: [
          gradientColors[1].withOpacity(0.3),
          gradientColors[1].withOpacity(0),
        ],
        stops: const [0.0, 1.0],
      );

      orbPaint.shader = gradient.createShader(
        Rect.fromCircle(center: orb, radius: 50),
      );

      canvas.drawCircle(orb, 50, orbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedBackgroundPainter oldDelegate) => true;
}

class AnimatedBackground extends StatefulWidget {
  final bool isDarkMode;

  const AnimatedBackground({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<AnimatedParticle>? particles;
  final int numberOfParticles = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get gradientColors => widget.isDarkMode
      ? [
          const Color(0xFF1A1A2E),
          const Color(0xFF16213E),
          const Color(0xFF0F3460),
          const Color(0xFF1A1A2E),
        ]
      : [
          const Color(0xFFE3F2FD),
          const Color(0xFFBBDEFB),
          const Color(0xFF90CAF9),
          const Color(0xFFE3F2FD),
        ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Initialize particles with actual screen size
        particles ??= List.generate(
          numberOfParticles,
          (index) => AnimatedParticle.random(size),
        );

        return SizedBox(
          width: size.width,
          height: size.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedBackgroundPainter(
                  animation: _controller,
                  isDarkMode: widget.isDarkMode,
                  particles: particles!,
                  gradientColors: gradientColors,
                  screenSize: size,
                ),
                size: size,
              );
            },
          ),
        );
      },
    );
  }
} 