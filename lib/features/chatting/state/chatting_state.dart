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
  return data
      .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
      .toList();
});
