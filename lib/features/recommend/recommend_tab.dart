import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/recommend/model/recommend_category.dart';
import 'package:madcamp_lounge/features/recommend/recommend_places_page.dart';
import 'package:madcamp_lounge/features/recommend/ui/widgets/category_tile.dart';
import 'package:madcamp_lounge/features/recommend/ui/widgets/recommend_appbar.dart';

class RecommendTab extends ConsumerWidget {
  const RecommendTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(preferredSize:
      const Size.fromHeight(kToolbarHeight),
        child: RecommendAppbar(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final c = recommendCategories[index];
                    return CategoryTile(
                      category: c,
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecommendListPage(category: c),
                            ),
                        );
                      },
                      gradientColor: generateRandomMaterialColor(),
                    );
                  },
                  childCount: recommendCategories.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color generateRandomMaterialColor() {
  final Random _random = Random();
  // Select a random color from the list of primary material colors
  return Colors.primaries[_random.nextInt(Colors.primaries.length)];
}
