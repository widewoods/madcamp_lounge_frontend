import 'package:flutter/material.dart';
import 'package:madcamp_lounge/main.dart';

class FixedField extends StatelessWidget {
  const FixedField({
    required this.ctrl,
    super.key,
  });

  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: 1,
      enabled: false,
      decoration: inputDecoration(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: Color(0xFF111827),
      ),
    );
  }
}