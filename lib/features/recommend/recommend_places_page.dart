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
    final asyncPlaces = ref.watch(recommendPlacesProvider(category));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category.title),
        centerTitle: true,
      ),
      body: asyncPlaces.when(
        data: (places) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => PlaceCard(
            place: places[i],
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => _PlaceDetailDialog(
                  title: places[i].name,
                  address: places[i].address,
                  distanceKm: places[i].distanceKm,
                ),
              );
            },
          ),
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

class _PlaceDetailDialog extends StatelessWidget {
  const _PlaceDetailDialog({
    required this.title,
    required this.address,
    required this.distanceKm,
  });

  final String title;
  final String address;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text("${distanceKm.toStringAsFixed(1)}km", style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("닫기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
