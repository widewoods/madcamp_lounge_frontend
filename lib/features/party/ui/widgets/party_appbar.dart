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
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: onClick,
          icon: Icon(Icons.add),
          label: const Text("파티 만들기"),
        )
      ],
    );
  }
}


