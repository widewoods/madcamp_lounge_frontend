import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/recommend_category.dart';
import 'state/recommend_providers.dart';
import 'ui/widgets/place_card.dart';

class RecommendListPage extends ConsumerWidget {
  const RecommendListPage({super.key, required this.category});
  final RecommendCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlaces = ref.watch(allPlacesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category.title),
        centerTitle: true,
      ),
      body: asyncPlaces.when(
        data: (places) => places[category.id]!.isNotEmpty ? ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: places[category.id]!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => PlaceCard(
            place: places[category.id]![i],
          ),
          ) : Center(child: Text("근처에 검색된 장소가 없습니다."),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text("불러오기에 실패했습니다.\n$e"),
          ),
        ),
      ),
    );
  }
}
