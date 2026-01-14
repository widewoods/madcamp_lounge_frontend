class ChatMessage {
  final int messageId;
  final int senderId;
  final String content;
  final DateTime sentAt;
  final int unreadCount;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.unreadCount,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: (json['message_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      content: json['content'].toString(),
      sentAt: DateTime.parse(json['sent_at'].toString()),
      unreadCount: (json['unread_count'] ?? 0) as int,
    );
  }
}
