class ChatRoom {
  final int roomId;
  final int? partyId;
  final String? partyTitle;
  final DateTime? createdAt;
  final int unreadCount;

  ChatRoom({
    required this.roomId,
    required this.partyId,
    required this.partyTitle,
    required this.createdAt,
    required this.unreadCount,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    DateTime? createdAt;
    if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    return ChatRoom(
      roomId: (json['room_id'] as num).toInt(),
      partyId: json['party_id'] == null ? null : (json['party_id'] as num).toInt(),
      partyTitle: json['party_title']?.toString(),
      createdAt: createdAt,
      unreadCount: (json['unread_count'] ?? 0) as int,
    );
  }
}
