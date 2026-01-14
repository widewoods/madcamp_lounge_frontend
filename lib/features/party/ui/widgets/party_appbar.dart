import 'package:flutter/material.dart';
import 'package:madcamp_lounge/gradient_button.dart';
import 'package:madcamp_lounge/theme.dart';

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
      actionsPadding: EdgeInsets.only(right: 10.0),
      actions: [
        GradientButton(
          onPressed: onClick,
          height: 45,
          icon: Icon(Icons.add, color: Colors.white,),
          colors: gradientColor,
          text: "파티 만들기",
        )
      ],
    );
  }
}


