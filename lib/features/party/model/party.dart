class Party {
  Party({
    required this.title,
    required this.category,
    required this.timeText,
    required this.locationText,
    required this.currentCount,
    required this.targetCount,
    required this.imageUrl,
    this.isLiked = false,
  });

  final String title;
  final String category;
  final String timeText;
  final String locationText;
  final int currentCount;
  final int targetCount;
  final String imageUrl;
  bool isLiked;

  factory Party.fromJson(Map<String, dynamic> json){
    return Party(
      title: json['title'].toString(),
      category: json['category'].toString(),
      timeText: json['appointmentTime'].toString(),
      locationText: json['placeName'].toString(),
      currentCount: json['currentCapacity'] as int,
      targetCount: json['targetCount'] as int,
      imageUrl: "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
      isLiked: false,
    );
  }
}