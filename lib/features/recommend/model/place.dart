class Place {
  final String categoryId;
  final String name;
  final String address;
  final double distanceKm;
  final double lat;
  final double lng;

  const Place({
    required this.categoryId,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.lat,
    required this.lng,
  });
}
