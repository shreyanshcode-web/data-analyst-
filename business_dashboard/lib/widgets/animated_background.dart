import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;
  final bool enableParallax;

  const AnimatedBackground({
    Key? key,
    required this.child,
    this.isDarkMode = false,
    this.enableParallax = true,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateOffset(PointerEvent event) {
    if (!widget.enableParallax) return;
    
    final size = MediaQuery.of(context).size;
    setState(() {
      _offset = Offset(
        event.position.dx / size.width - 0.5,
        event.position.dy / size.height - 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _updateOffset,
      child: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_controller.value * 2 * math.pi) * 0.2 + _offset.dx,
                      math.sin(_controller.value * 2 * math.pi) * 0.2 + _offset.dy,
                    ),
                    end: Alignment(
                      -math.cos(_controller.value * 2 * math.pi) * 0.2 - _offset.dx,
                      -math.sin(_controller.value * 2 * math.pi) * 0.2 - _offset.dy,
                    ),
                    colors: widget.isDarkMode
                        ? [
                            Color(0xFF1A1A1A),
                            Color(0xFF2D2D2D),
                            Color(0xFF3D3D3D),
                          ]
                        : [
                            Color(0xFFF8F9FA),
                            Color(0xFFE9ECEF),
                            Color(0xFFDEE2E6),
                          ],
                  ),
                ),
              );
            },
          ),
          // Animated particles
          ...List.generate(30, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 10 + 5;
            final initialX = random.nextDouble() * MediaQuery.of(context).size.width;
            final initialY = random.nextDouble() * MediaQuery.of(context).size.height;
            
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _controller.value;
                final angle = progress * 2 * math.pi + index;
                final parallaxX = widget.enableParallax ? _offset.dx * (index % 3 + 1) * 30 : 0.0;
                final parallaxY = widget.enableParallax ? _offset.dy * (index % 3 + 1) * 30 : 0.0;
                
                return Positioned(
                  left: initialX + math.cos(angle) * 30 + parallaxX,
                  top: initialY + math.sin(angle) * 30 + parallaxY,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (widget.isDarkMode ? Colors.white : Colors.black)
                          .withOpacity(0.05),
                    ),
                  ),
                );
              },
            );
          }),
          // Content
          widget.child,
        ],
      ),
    );
  }
} 