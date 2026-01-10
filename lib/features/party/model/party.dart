class Party {
  Party({
    required this.title,
    required this.category,
    required this.timeText,
    required this.locationText,
    required this.current,
    required this.max,
    required this.imageUrl,
    this.isLiked = false,
  });

  final String title;
  final String category;
  final String timeText;
  final String locationText;
  final int current;
  final int max;
  final String imageUrl;
  bool isLiked;
}