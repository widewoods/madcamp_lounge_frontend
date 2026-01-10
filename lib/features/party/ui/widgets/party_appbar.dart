import 'package:flutter/material.dart';

class PartyAppBar extends StatelessWidget {
  const PartyAppBar({
    required this.onClick,
    super.key,
  });

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "파티원 구하기",
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onClick,
          icon: Icon(Icons.add),
          label: const Text("파티 만들기"),
        )
      ],
    );
  }
}


