import 'package:madcamp_lounge/features/recommend/model/recommend_category.dart';

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
    this.content,
    this.joined = false,
    required this.isHost,
  });

  int? partyId;
  final String title;
  final String category;
  final String time;
  final String locationText;
  final int currentCount;
  final int targetCount;
  final String imageUrl;
  final List<dynamic> members;
  bool joined;
  String? content;
  final bool isHost;
  final String defaultImage = "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80";


  factory Party.fromJson(Map<String, dynamic> json, int userId){
    final category = recommendCategories.where((e) => e.id == json['category'].toString()).toList();
    final party = Party(
      partyId: json['id'] as int,
      title: json['title'].toString(),
      category: json['category'].toString(),
      time: json['appointment_time'],
      locationText: json['place_name'].toString(),
      currentCount: json['current_capacity'] as int,
      targetCount: json['target_count'] as int,
      imageUrl: category.isNotEmpty ? category[0].imageUrl
          : "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
      content: json['content'].toString(),
      members: json['members'] as List<dynamic>,
      isHost: userId == json['host_id'],
    );
    party.joined = party.members.map((e) => e['user_id']).contains(userId);
    return party;
  }
}
