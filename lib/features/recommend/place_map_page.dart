import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/recommend/state/recommend_providers.dart';

class PlaceMapPage extends ConsumerWidget {
  const PlaceMapPage({
    super.key,
    required this.lat,
    required this.lng,
    required this.placeName,
  });

  final double lat;
  final double lng;
  final String placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placePosition = NLatLng(lat, lng);
    final safeAreaPadding = MediaQuery.paddingOf(context);

    final userPosAsync = ref.watch(currentPositionProvider); // AsyncValue<Position>

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "목록으로 돌아가기",
          style: TextStyle(
            fontSize: 18
          ),
        ),
        titleSpacing: 0.1,
      ),
      body: userPosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('위치 가져오기 실패: $e')),
        data: (userPos) {
          final userPosition = NLatLng(userPos.latitude, userPos.longitude);

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: NaverMap(
              options: NaverMapViewOptions(
                contentPadding: safeAreaPadding,
                initialCameraPosition: NCameraPosition(
                  target: placePosition,
                  zoom: 14,
                ),
              ),
              onMapReady: (controller) async {
                final poi = placePosition;
                final me = userPosition;

                final marker = NMarker(
                  id: "poi",
                  position: poi,
                  caption: NOverlayCaption(text: placeName),
                );
                await controller.addOverlay(marker);

                final meMarker = NMarker(
                  id: "me",
                  position: me,
                  caption: const NOverlayCaption(text: "내 위치"),
                );
                await controller.addOverlay(meMarker);

                final southWest = NLatLng(
                  (poi.latitude  < me.latitude)  ? poi.latitude  : me.latitude,
                  (poi.longitude < me.longitude) ? poi.longitude : me.longitude,
                );
                final northEast = NLatLng(
                  (poi.latitude  > me.latitude)  ? poi.latitude  : me.latitude,
                  (poi.longitude > me.longitude) ? poi.longitude : me.longitude,
                );

                final bounds = NLatLngBounds(southWest: southWest, northEast: northEast);

                final cameraUpdate = NCameraUpdate.fitBounds(
                  bounds,
                  padding: const EdgeInsets.all(60),
                );

                await controller.updateCamera(cameraUpdate);
              },
            ),
          );
        },
      ),
    );
  }
}
