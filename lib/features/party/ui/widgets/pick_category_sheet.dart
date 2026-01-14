import 'package:flutter/material.dart';
import 'package:madcamp_lounge/gradient_button.dart';
import 'package:madcamp_lounge/theme.dart';

import '../../../recommend/model/recommend_category.dart';

/// BottomSheet that lets user pick a category using chip-like buttons.
/// - 4 items per row
/// - returns the selected RecommendCategory (or null if dismissed)
Future<RecommendCategory?> showPickCategorySheet(BuildContext context) {
  return showModalBottomSheet<RecommendCategory>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.55, // same feel as time sheet
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "카테고리",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: recommendCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (_, i) {
                  final c = recommendCategories[i];

                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.pop(sheetContext, c),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF131313),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}