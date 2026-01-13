import 'package:geolocator/geolocator.dart';

import 'location_service.dart';
import 'models.dart';
import 'naver_search_api_client.dart';
import 'reverse_geocoding.dart';

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
}
