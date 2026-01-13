import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_room.dart';

final chatRoomListProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final res = await apiClient.get('/chat/rooms');
  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode}');
  }

  final data = jsonDecode(res.body) as List<dynamic>;
  final rooms = data
      .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
      .toList();
  rooms.sort((a, b) {
    final aTime = a.lastMessageAt ?? a.createdAt;
    final bTime = b.lastMessageAt ?? b.createdAt;
    if (aTime == null && bTime == null) {
      return b.roomId.compareTo(a.roomId);
    }
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  });
  return rooms;
});
