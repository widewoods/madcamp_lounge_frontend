import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:madcamp_lounge/features/recommend/searchAPI/reverse_geocoding.dart';

import 'models.dart';
import 'naver_search_api_client.dart';

class RecommendSearchService {
  static NcpReverseGeocodeClient reverseGeocodeClient = NcpReverseGeocodeClient();
  static NaverSearchApiClient localSearchClient = NaverSearchApiClient();

  static Future<List<NaverLocalItem>> searchNearby({
    required String categoryKeyword,
    required double radiusKm,
    required Position pos,
  }) async {
    final hint = await reverseGeocodeClient.reverseGeocodeHint(
      lat: pos.latitude,
      lon: pos.longitude,
    );

    final query = hint.trim().isEmpty
        ? '근처 $categoryKeyword'
        : '$hint 근처 $categoryKeyword';

    return localSearchClient.searchNearby(
      keyword: query,
      myLat: pos.latitude,
      myLon: pos.longitude,
      radiusKm: radiusKm,
      maxResults: 5,
    );
  }

  static Future<List<NaverLocalItem>> searchNearbyExpanded({
    required String categoryKeyword,
    required double radiusKm,
    required Position pos,
    double? offsetKm,
    int finalMax = 20,
  }) async {

    final moveKm = offsetKm ?? (radiusKm * 0.5);

    final centers = <LatLon>[
      LatLon(pos.latitude, pos.longitude), // center
      offsetByKm(lat: pos.latitude, lon: pos.longitude, northKm: 0, eastKm: moveKm),   // east
      offsetByKm(lat: pos.latitude, lon: pos.longitude, northKm: 0, eastKm: -moveKm),  // west
      offsetByKm(lat: pos.latitude, lon: pos.longitude, northKm: moveKm, eastKm: 0),   // north
      offsetByKm(lat: pos.latitude, lon: pos.longitude, northKm: -moveKm, eastKm: 0),  // south
    ];

    final placeList = await Future.wait(
      centers.map((c) {
        return reverseGeocodeClient.reverseGeocodeHint(
          lat: c.lat,
          lon: c.lon,
        );
      })
    );

    final placeListDistinct = placeList.toSet().toList();

    final resultsList = await Future.wait(
      placeListDistinct.map((c) {
        final hint = c.trim();
        final query = hint.isEmpty
            ? '$categoryKeyword'
            : '$hint $categoryKeyword';

        return localSearchClient.searchNearby(
          keyword: query,
          myLat: pos.latitude,
          myLon: pos.longitude,
          radiusKm: radiusKm,
          maxResults: 5,
        );
      }),
    );

    final all = resultsList.expand((x) => x).toList();

    final seen = <String>{};
    final deduped = <NaverLocalItem>[];

    for (final item in all) {
      final key = '${item.title}|${item.lat}|${item.lon}';
      if (seen.add(key)) deduped.add(item);
    }

    deduped.sort((a, b) {
      final da = Geolocator.distanceBetween(
        pos.latitude, pos.longitude,
        a.lat, a.lon,
      );
      final db = Geolocator.distanceBetween(
        pos.latitude, pos.longitude,
        b.lat, b.lon,
      );
      return da.compareTo(db);
    });

    return deduped.take(finalMax).toList();
  }
}

class LatLon {
  final double lat;
  final double lon;
  const LatLon(this.lat, this.lon);
}

LatLon offsetByKm({
  required double lat,
  required double lon,
  required double northKm,
  required double eastKm,
}) {
  final dLat = northKm / 110.574;

  final latRad = lat * pi / 180.0;
  final kmPerDegLon = 111.320 * cos(latRad).abs().clamp(0.000001, 1.0);
  final dLon = eastKm / kmPerDegLon;

  return LatLon(lat + dLat, lon + dLon);
}

