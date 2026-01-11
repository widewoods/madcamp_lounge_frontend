import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/recommend/ui/widgets/recommend_appbar.dart';

class RecommendTab extends StatefulWidget {
  const RecommendTab({super.key});

  @override
  State<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<RecommendTab> {

  final List<Widget> categoryButtons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize:
        const Size.fromHeight(kToolbarHeight),
          child: RecommendAppbar(),
        ),
      body: GridView.count(
        primary: false,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: categoryButtons
      ),
    );
  }
}
