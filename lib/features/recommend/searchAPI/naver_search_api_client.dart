import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:madcamp_lounge/main.dart';

import 'distance_filter.dart';
import 'models.dart';

class NaverSearchApiClient {
  final String clientId = naverSearchClientID;
  final String clientSecret = naverSearchClientSecret;

  final http.Client _http;

  final bool assumeE7ScaledWgs84;

  NaverSearchApiClient({
    http.Client? httpClient,
    this.assumeE7ScaledWgs84 = true,
  }) : _http = httpClient ?? http.Client();

  void close() => _http.close();

  Future<List<NaverLocalItem>> searchNearby({
    required String keyword,
    required double myLat,
    required double myLon,
    required double radiusKm,
    int maxResults = 5,
    int display = 5,
    int start = 1,
    String sort = 'comment',
  }) async {
    if (keyword.trim().isEmpty) {
      throw SearchApiException('keyword is empty');
    }
    if (radiusKm <= 0) {
      throw SearchApiException('radiusKm must be > 0');
    }
    if (maxResults <= 0) {
      return const [];
    }

    final uri = Uri.https('openapi.naver.com', '/v1/search/local.json', {
      'query': keyword,
      'display': display.toString(),
      'start': start.toString(),
      'sort': sort,
    });

    final res = await _http.get(uri, headers: {
      'X-Naver-Client-Id': clientId,
      'X-Naver-Client-Secret': clientSecret,
    });

    if (res.statusCode != 200) {
      throw SearchApiException(
        'Naver local search failed: ${res.body}',
        statusCode: res.statusCode,
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw SearchApiException('Unexpected response format');
    }

    final rawItems = decoded['items'];
    if (rawItems is! List) {
      throw SearchApiException('Missing items in response');
    }

    final results = <NaverLocalItem>[];

    for (final e in rawItems) {
      if (e is! Map<String, dynamic>) continue;

      final rawTitle = (e['title'] ?? '').toString();
      final title = rawTitle.replaceAll(RegExp(r'<[^>]+>'), '');

      final category = (e['category'] ?? '').toString();
      final address = (e['address'] ?? '').toString();
      final roadAddress = (e['roadAddress'] ?? '').toString();

      final mapx = double.tryParse((e['mapx'] ?? '').toString());
      final mapy = double.tryParse((e['mapy'] ?? '').toString());
      if (mapx == null || mapy == null) continue;

      final lon = assumeE7ScaledWgs84 ? mapx / 1e7 : mapx;
      final lat = assumeE7ScaledWgs84 ? mapy / 1e7 : mapy;

      final dKm = haversineKm(myLat, myLon, lat, lon);
      if (dKm > radiusKm) continue;

      results.add(NaverLocalItem(
        title: title,
        category: category,
        address: address,
        roadAddress: roadAddress,
        lat: lat,
        lon: lon,
        distanceKm: dKm,
      ));
    }

    return results;
  }
}
