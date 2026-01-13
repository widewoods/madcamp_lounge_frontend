import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_message.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_room_detail.dart';

class ChatRoomDetailState {
  final bool loading;
  final bool loadingMore;
  final String? error;
  final ChatRoomDetail? detail;

  const ChatRoomDetailState({
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.detail,
  });

  ChatRoomDetailState copyWith({
    bool? loading,
    bool? loadingMore,
    String? error,
    ChatRoomDetail? detail,
  }) {
    return ChatRoomDetailState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      detail: detail ?? this.detail,
    );
  }

  static ChatRoomDetailState initial() {
    return const ChatRoomDetailState(
      loading: true,
      loadingMore: false,
      error: null,
      detail: null,
    );
  }
}

class ChatRoomDetailNotifier extends StateNotifier<ChatRoomDetailState> {
  ChatRoomDetailNotifier(this._ref, this._roomId) : super(ChatRoomDetailState.initial());

  final Ref _ref;
  final int _roomId;

  Future<void> loadInitial() async {
    state = state.copyWith(loading: true, error: null);
    final apiClient = _ref.read(apiClientProvider);
    final res = await apiClient.get('/chat/chatroom?room_id=$_roomId');
    if (res.statusCode != 200) {
      state = state.copyWith(
        loading: false,
        error: 'Failed: ${res.statusCode}',
      );
      return;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final detail = ChatRoomDetail.fromJson(data);
    final ordered = detail.messages.reversed.toList();
    final adjusted = detail.copyWith(messages: ordered);
    state = state.copyWith(loading: false, detail: adjusted, error: null);
  }

  Future<void> loadMore() async {
    final detail = state.detail;
    if (detail == null || !detail.hasMore || state.loadingMore) {
      return;
    }

    state = state.copyWith(loadingMore: true);
    final apiClient = _ref.read(apiClientProvider);
    final cursor = detail.nextCursor?.toIso8601String();
    final cursorId = detail.nextCursorId;
    final uri = StringBuffer('/chat/history?room_id=$_roomId');
    if (cursor != null) {
      uri.write('&next_cursor=$cursor');
    }
    if (cursorId != null) {
      uri.write('&next_cursor_id=$cursorId');
    }

    final res = await apiClient.get(uri.toString());
    if (res.statusCode != 200) {
      state = state.copyWith(loadingMore: false);
      return;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final messagesRaw = (data['messages'] as List<dynamic>)
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
    final olderMessages = messagesRaw.reversed.toList();

    final merged = [
      ...olderMessages,
      ...detail.messages,
    ];

    final updated = detail.copyWith(
      messages: merged,
      nextCursor: data['next_cursor'] == null
          ? null
          : DateTime.tryParse(data['next_cursor'].toString()),
      nextCursorId: data['next_cursor_id'] == null
          ? null
          : (data['next_cursor_id'] as num).toInt(),
      hasMore: data['has_more'] == true,
    );

    state = state.copyWith(loadingMore: false, detail: updated);
  }

  void appendMessage(ChatMessage message) {
    final detail = state.detail;
    if (detail == null) {
      return;
    }
    final updated = detail.copyWith(messages: [...detail.messages, message]);
    state = state.copyWith(detail: updated);
  }
}

final chatRoomDetailProvider = StateNotifierProvider.family<
    ChatRoomDetailNotifier,
    ChatRoomDetailState,
    int>((ref, roomId) {
  return ChatRoomDetailNotifier(ref, roomId);
});
