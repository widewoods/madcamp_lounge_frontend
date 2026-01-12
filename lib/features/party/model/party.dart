import '../date_formatting.dart';

class Party {
  Party({
    this.partyId,
    required this.title,
    required this.category,
    required this.time,
    required this.locationText,
    required this.currentCount,
    required this.targetCount,
    required this.imageUrl,
    required this.members,
    this.isLiked = false,
    this.joined = false,
  });

  int? partyId;
  final String title;
  final String category;
  final String time;
  final String locationText;
  final int currentCount;
  final int targetCount;
  final String imageUrl;
  final List<Map<String, dynamic>> members;
  bool isLiked;
  bool joined;

  factory Party.fromJson(Map<String, dynamic> json){
    final formattedTime = formatIsoKorean(parseIso(json['appointment_time']));

    return Party(
      partyId: json['id'] as int,
      title: json['title'].toString(),
      category: json['category'].toString(),
      time: formattedTime,
      locationText: json['place_name'].toString(),
      currentCount: json['current_capacity'] as int,
      targetCount: json['target_count'] as int,
      imageUrl: "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
      isLiked: false,
      // Todo: get members
      members: []
      // members: json['members'] as List<Map<String, dynamic>>
    );
  }
}
