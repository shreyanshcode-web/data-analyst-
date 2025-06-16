import 'package:flutter/material.dart';

class Modern3DCard extends StatefulWidget {
  final Widget child;
  final double elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const Modern3DCard({
    Key? key,
    required this.child,
    this.elevation = 4.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  State<Modern3DCard> createState() => _Modern3DCardState();
}

class _Modern3DCardState extends State<Modern3DCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _isHovered ? -widget.elevation : 0.0,
            0.0,
          ),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, _isHovered ? widget.elevation * 1.5 : widget.elevation),
              blurRadius: widget.elevation * 2,
              spreadRadius: -widget.elevation / 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
} 