import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  const EditableField({
    required this.ctrl,
    required this.isEditing,
    this.maxLength,
    super.key,
  });

  final TextEditingController ctrl;
  final bool isEditing;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: null,
      enabled: isEditing,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: Color(0xFF111827),
      ),
      decoration: InputDecoration(
          filled: isEditing
      ),
      maxLength: maxLength,
    );
  }
}