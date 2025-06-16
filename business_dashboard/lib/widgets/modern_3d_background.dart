import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Modern3DBackground extends StatefulWidget {
  final bool isDarkMode;
  final bool enableParallax;

  const Modern3DBackground({
    Key? key,
    this.isDarkMode = false,
    this.enableParallax = true,
  }) : super(key: key);

  @override
  State<Modern3DBackground> createState() => _Modern3DBackgroundState();
}

class _Modern3DBackgroundState extends State<Modern3DBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _offset = Offset.zero;

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
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDarkMode
                    ? [
                        Color(0xFF1A1A1A),
                        Color(0xFF2D2D2D),
                      ]
                    : [
                        Color(0xFFF8F9FA),
                        Color(0xFFE9ECEF),
                      ],
              ),
            ),
          ),
          // Animated patterns
          ...List.generate(20, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 100 + 50;
            final initialX = random.nextDouble() * MediaQuery.of(context).size.width;
            final initialY = random.nextDouble() * MediaQuery.of(context).size.height;
            
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _controller.value;
                final angle = progress * 2 * math.pi + index;
                final parallaxX = widget.enableParallax ? _offset.dx * (index % 3 + 1) * 20 : 0.0;
                final parallaxY = widget.enableParallax ? _offset.dy * (index % 3 + 1) * 20 : 0.0;
                
                return Positioned(
                  left: initialX + math.cos(angle) * 20 + parallaxX,
                  top: initialY + math.sin(angle) * 20 + parallaxY,
                  child: Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isDarkMode
                              ? [
                                  Colors.blue.withOpacity(0.1),
                                  Colors.purple.withOpacity(0.1),
                                ]
                              : [
                                  Colors.blue.withOpacity(0.05),
                                  Colors.purple.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(size / 2),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
} 