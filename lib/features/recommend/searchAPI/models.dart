class NaverLocalItem {
  final String title;
  final String category;
  final String address;
  final String roadAddress;
  final double lat;
  final double lon;
  final double distanceKm;

  const NaverLocalItem({
    required this.title,
    required this.category,
    required this.address,
    required this.roadAddress,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });
}

class SearchApiException implements Exception {
  final int? statusCode;
  final String message;

  SearchApiException(this.message, {this.statusCode});

  @override
  String toString() => 'SearchApiException(statusCode=$statusCode, message=$message)';
}
