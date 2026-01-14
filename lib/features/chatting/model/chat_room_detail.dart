import 'package:madcamp_lounge/features/chatting/model/chat_member.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_message.dart';

class ChatRoomDetail {
  final int roomId;
  final int? partyId;
  final String? partyTitle;
  final DateTime? createdAt;
  final List<ChatMember> members;
  final List<ChatMessage> messages;
  final int? lastReadMessageId;
  final DateTime? nextCursor;
  final int? nextCursorId;
  final bool hasMore;

  ChatRoomDetail({
    required this.roomId,
    required this.partyId,
    required this.partyTitle,
    required this.createdAt,
    required this.members,
    required this.messages,
    required this.lastReadMessageId,
    required this.nextCursor,
    required this.nextCursorId,
    required this.hasMore,
  });

  ChatRoomDetail copyWith({
    List<ChatMessage>? messages,
    int? lastReadMessageId,
    DateTime? nextCursor,
    int? nextCursorId,
    bool? hasMore,
  }) {
    return ChatRoomDetail(
      roomId: roomId,
      partyId: partyId,
      partyTitle: partyTitle,
      createdAt: createdAt,
      members: members,
      messages: messages ?? this.messages,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      nextCursor: nextCursor ?? this.nextCursor,
      nextCursorId: nextCursorId ?? this.nextCursorId,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory ChatRoomDetail.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>;
    final createdAtRaw = room['created_at']?.toString();
    DateTime? createdAt;
    if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.parse(createdAtRaw).add(Duration(hours: 9));
    }

    final members = (json['members'] as List<dynamic>)
        .map((item) => ChatMember.fromJson(item as Map<String, dynamic>))
        .toList();
    final messages = (json['messages'] as List<dynamic>)
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();

    return ChatRoomDetail(
      roomId: (room['room_id'] as num).toInt(),
      partyId: room['party_id'] == null ? null : (room['party_id'] as num).toInt(),
      partyTitle: room['party_title']?.toString(),
      createdAt: createdAt,
      members: members,
      messages: messages,
      lastReadMessageId: json['last_read_message_id'] == null
          ? null
          : (json['last_read_message_id'] as num).toInt(),
      nextCursor: json['next_cursor'] == null
          ? null
          : DateTime.tryParse(json['next_cursor'].toString()),
      nextCursorId: json['next_cursor_id'] == null
          ? null
          : (json['next_cursor_id'] as num).toInt(),
      hasMore: json['has_more'] == true,
    );
  }
}
