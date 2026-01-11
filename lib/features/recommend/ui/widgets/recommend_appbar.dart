import 'package:flutter/material.dart';

class RecommendAppbar extends StatelessWidget {
  const RecommendAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        "놀거리 추천",
        textAlign: TextAlign.left,
      ),
    );
  }
}


