import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final VoidCallback? onTap;

  const CustomIconWidget({
    Key? key,
    required this.icon,
    this.color,
    this.size,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          color: color ?? Theme.of(context).iconTheme.color,
          size: size,
        ),
      ),
    );
  }
} 