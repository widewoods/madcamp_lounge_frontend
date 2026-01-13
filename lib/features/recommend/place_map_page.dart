import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class PlaceMapPage extends StatelessWidget {
  const PlaceMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    const seoulCityHall = NLatLng(37.5666, 126.979);
    final safeAreaPadding = MediaQuery.paddingOf(context);
    return Scaffold(
      body: NaverMap(
        options: NaverMapViewOptions(
          contentPadding: safeAreaPadding,
          initialCameraPosition: NCameraPosition(target: seoulCityHall, zoom: 14),
        ),
        onMapReady: (controller) {
          final marker = NMarker(
            id: "city_hall",
            position: seoulCityHall,
            caption: NOverlayCaption(text: "서울시청"),
          );
          controller.addOverlay(marker);
        },
      ),
    );
  }
}
