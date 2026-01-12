import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/place.dart';
import '../model/recommend_category.dart';

final allPlacesProvider = Provider<List<Place>>((ref) {
  return const [
    Place(
      id: 'p1',
      categoryId: 'boardgame',
      name: '루미큐브 보드게임카페',
      address: '대전 유성구 어딘가 1',
      priceText: '1인 3,000원~',
      hoursText: '영업중 · 22:00 마감',
      distanceKm: 0.7,
    ),
    Place(
      id: 'p2',
      categoryId: 'boardgame',
      name: '카드왕 보드게임',
      address: '대전 유성구 어딘가 2',
      priceText: '1인 4,000원~',
      hoursText: '영업중 · 24:00 마감',
      distanceKm: 1.2,
    ),
    Place(
      id: 'p3',
      categoryId: 'bowling',
      name: '레인 볼링장',
      address: '대전 서구 어딘가',
      priceText: '게임 4,500원~',
      hoursText: '영업중 · 01:00 마감',
      distanceKm: 1.5,
    ),
    Place(
      id: 'p4',
      categoryId: 'cafe',
      name: '카페 샘플 A',
      address: '대전 어딘가',
      priceText: '아메리카노 4,000원~',
      hoursText: '영업중 · 21:00 마감',
      distanceKm: 0.9,
    ),
  ];
});

final recommendPlacesProvider = FutureProvider.family<List<Place>, RecommendCategory>((ref, category) async {
  await Future<void>.delayed(const Duration(milliseconds: 250));

  // TODO: Map API 붙일 때는 여기서 categoryId에 맞는 keyword로 검색해서 결과를 Place로 매핑하세요.
  // 지금은 전체 리스트에서 categoryId로 필터링
  final all = ref.read(allPlacesProvider);

  final filtered = all.where((p) => p.categoryId == category.id).toList();

  filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

  return filtered;
});
