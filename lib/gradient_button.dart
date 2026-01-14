import 'dart:ui';

import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 46,
    this.borderRadius = 14,
    this.icon,
    this.fontSize,
    required this.colors,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final double? fontSize;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: Ink(
        height: height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: AlignmentGeometry.topLeft,
            radius: 4.0,
            colors: isEnabled
                ? colors
                : [Colors.grey.shade300, Colors.grey.shade300],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 10.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style:  TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontSize: fontSize ?? 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
