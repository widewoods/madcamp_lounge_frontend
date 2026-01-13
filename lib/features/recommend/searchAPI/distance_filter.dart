import 'dart:math';


double _deg2rad(double d) => d * pi / 180.0;
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  return num.parse((2 * R * atan2(sqrt(a), sqrt(1 - a))).toStringAsFixed(2)) as double;
}

List<Map<String, dynamic>> filterByDist(List<Map<String, dynamic>> searchList) {
  searchList.sort((a, b) => (a['distanceKm'] as double).compareTo(b['distanceKm'] as double));
  if(searchList.length > 10) return searchList.sublist(0, 10);
  return searchList;
}