class ChatMember {
  final int userId;
  final String name;
  final String nickname;
  final String classSection;

  ChatMember({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.classSection,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: (json['user_id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      classSection: (json['class_section'] ?? '').toString(),
    );
  }
}
