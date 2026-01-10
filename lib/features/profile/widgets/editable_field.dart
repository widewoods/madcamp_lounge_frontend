import 'package:flutter/material.dart';
import 'package:madcamp_lounge/main.dart';

class EditableField extends StatelessWidget {
  const EditableField({
    required this.ctrl,
    required this.isEditing,
    super.key,
  });

  final TextEditingController ctrl;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: 1,
      enabled: isEditing,
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