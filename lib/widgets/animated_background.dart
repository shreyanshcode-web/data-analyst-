import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<AnimatedParticle> _particles = [];
  final int _numberOfParticles = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < _numberOfParticles; i++) {
      _particles.add(AnimatedParticle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _controller,
              ),
              child: Container(),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class AnimatedParticle {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = math.Random().nextDouble() * 3 + 1;
  final double speed = math.Random().nextDouble() * 0.3 + 0.1;
  final double angle = math.Random().nextDouble() * 2 * math.pi;
  final double opacity = math.Random().nextDouble() * 0.3 + 0.1;
}

class ParticlePainter extends CustomPainter {
  final List<AnimatedParticle> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.blue.withOpacity(particle.opacity),
            Colors.purple.withOpacity(particle.opacity * 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      final x = (particle.x + 
        math.cos(particle.angle + animation.value * particle.speed) * 0.2 +
        math.sin(animation.value * 0.5) * 0.1) * size.width;
      
      final y = (particle.y + 
        math.sin(particle.angle + animation.value * particle.speed) * 0.2 +
        math.cos(animation.value * 0.5) * 0.1) * size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );

      for (var other in particles) {
        if (other != particle) {
          final distance = math.sqrt(
            math.pow(x - (other.x * size.width), 2) + 
            math.pow(y - (other.y * size.height), 2)
          );
          
          if (distance < 100) {
            final linePaint = Paint()
              ..color = Colors.blue.withOpacity(0.1 * (1 - distance / 100))
              ..strokeWidth = 1;
            
            canvas.drawLine(
              Offset(x, y),
              Offset(other.x * size.width, other.y * size.height),
              linePaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 