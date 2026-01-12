class Place {
  final String id;
  final String categoryId;

  final String name;

  final String address;
  final String priceText;
  final String hoursText;
  final double distanceKm;

  const Place({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.address,
    required this.priceText,
    required this.hoursText,
    required this.distanceKm,
  });
}
