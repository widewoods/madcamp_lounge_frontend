import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madcamp_lounge/main.dart';

import 'models.dart';

class NcpReverseGeocodeClient {
  final String keyId = ncpClientID;
  final String key = ncpClientKey;
  final http.Client _http;

  final String host;

  NcpReverseGeocodeClient({
    http.Client? httpClient,
    this.host = 'maps.apigw.ntruss.com',
  }) : _http = httpClient ?? http.Client();

  void close() => _http.close();

  Future<String> reverseGeocodeHint({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.https(host, '/map-reversegeocode/v2/gc', {
      'request': 'coordsToaddr',
      'coords': '$lon,$lat',
      'sourcecrs': 'epsg:4326',
      'orders': 'roadaddr,addr,admcode,legalcode',
      'output': 'json',
    });

    final res = await _http.get(uri, headers: {
      'X-NCP-APIGW-API-KEY-ID': keyId,
      'X-NCP-APIGW-API-KEY': key,
    });

    if (res.statusCode != 200) {
      throw SearchApiException('Reverse geocode failed: ${res.body}', statusCode: res.statusCode);
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw SearchApiException('Reverse geocode: unexpected response');
    }

    final results = decoded['results'];
    if (results is! List || results.isEmpty) {
      return '';
    }

    // 응답이 orders 순서대로 나오므로, roadaddr 쪽에서 건물명(addition0.value)이 있으면 우선 사용
    String? building;
    String area1 = '', area2 = '', area3 = '';

    for (final r in results) {
      if (r is! Map<String, dynamic>) continue;

      final region = r['region'];
      if (region is Map<String, dynamic>) {
        area1 = (region['area1']?['name'] ?? '').toString();
        area2 = (region['area2']?['name'] ?? '').toString();
        area3 = (region['area3']?['name'] ?? '').toString();
      }

      final land = r['land'];
      if (land is Map<String, dynamic>) {
        final add0 = land['addition0'];
        if (add0 is Map<String, dynamic>) {
          final type = (add0['type'] ?? '').toString();
          final value = (add0['value'] ?? '').toString();
          if (type == 'building' && value.isNotEmpty) {
            building = value;
          }
        }
      }
    }

    // 예: "카이스트"처럼 건물/기관명이 나오면 그걸, 아니면 행정구역 조합
    if (building != null && building!.isNotEmpty) return building!;
    final parts = [area1, area2, area3].where((s) => s.trim().isNotEmpty).toList();
    return parts.join(' ');
  }
}
