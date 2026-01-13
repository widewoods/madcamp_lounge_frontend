import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:madcamp_lounge/features/recommend/searchAPI/location_service.dart';
import 'package:madcamp_lounge/features/recommend/searchAPI/models.dart';
import 'package:madcamp_lounge/features/recommend/searchAPI/recommend_search_service.dart';
import 'package:pool/pool.dart';
import '../model/place.dart';
import '../model/recommend_category.dart';

final currentPositionProvider = FutureProvider<Position>((ref) async {
  ref.keepAlive();
  final locationService = LocationService();
  return locationService.getCurrentPosition();
});

final allPlacesProvider = FutureProvider<Map<String, List<Place>>>((ref) async {
  final pos = await ref.watch(currentPositionProvider.future);

  final Map<String, List<Place>> map = {};

  for (final category in recommendCategories) {
    final results = await RecommendSearchService.searchNearby(
      pos: pos,
      categoryKeyword: category.keyword,
      radiusKm: 4,
    );

    final places = results
        .map((r) => Place(
      categoryId: category.id,
      name: r.title,
      address: r.address,
      distanceKm: r.distanceKm,
      lat: r.lat,
      lng: r.lon,
    ))
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    map[category.id] = places;
  }

  return map;

});