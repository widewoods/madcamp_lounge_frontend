class ChatMessage {
  final int messageId;
  final int senderId;
  final String content;
  final DateTime sentAt;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: (json['message_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      content: json['content'].toString(),
      sentAt: DateTime.parse(json['sent_at'].toString()).add(Duration(hours: 9)),
    );
  }
}
