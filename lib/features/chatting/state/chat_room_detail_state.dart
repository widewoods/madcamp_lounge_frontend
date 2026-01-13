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

  // 1. 초기 로드: 최신순으로 정렬 (Index 0이 가장 최신)
  Future<void> loadInitial() async {
    state = state.copyWith(loading: true, error: null);
    final apiClient = _ref.read(apiClientProvider);
    final res = await apiClient.get('/chat/chatroom?room_id=$_roomId');

    if (res.statusCode != 200) {
      state = state.copyWith(loading: false, error: 'Failed: ${res.statusCode}');
      return;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final detail = ChatRoomDetail.fromJson(data);

    final orderedMessages = [...detail.messages]
      ..sort((a, b) {
        final timeCompare = b.sentAt.compareTo(a.sentAt);
        if (timeCompare != 0) return timeCompare;
        return b.messageId.compareTo(a.messageId);
      });

    state = state.copyWith(
        loading: false,
        detail: detail.copyWith(messages: orderedMessages),
        error: null
    );
  }

  // 2. 과거 메시지 추가 로드: 리스트의 끝(뒤쪽)에 붙임
  Future<bool> loadMore() async {
    final detail = state.detail;
    if (detail == null || !detail.hasMore || state.loadingMore) return false;

    state = state.copyWith(loadingMore: true);

    try {
      final cursor = detail.nextCursor?.toIso8601String();
      final cursorId = detail.nextCursorId;

      final uri = '/chat/history?room_id=$_roomId'
          '${cursor != null ? "&next_cursor=$cursor" : ""}'
          '${cursorId != null ? "&next_cursor_id=$cursorId" : ""}';

      final res = await _ref.read(apiClientProvider).get(uri);
      if (res.statusCode != 200) throw Exception("Failed to load");

      final data = jsonDecode(res.body);
      final List<dynamic> messagesJson = data['messages'];

      // API가 가져온 더 과거의 메시지들
      final olderMessages = messagesJson
          .map((m) => ChatMessage.fromJson(m))
          .toList()
        ..sort((a, b) {
          final timeCompare = b.sentAt.compareTo(a.sentAt);
          if (timeCompare != 0) return timeCompare;
          return b.messageId.compareTo(a.messageId);
        });

      // [핵심] 기존 메시지(최신쪽) 뒤에 새로 가져온 메시지(더 과거쪽)를 붙임
      // reverse: true에서 리스트 뒷부분이 화면상 '위'가 됩니다.
      final mergedMessages = [...detail.messages, ...olderMessages];

      state = state.copyWith(
        loadingMore: false,
        detail: detail.copyWith(
          messages: mergedMessages,
          nextCursor: data['next_cursor'] != null ? DateTime.tryParse(data['next_cursor'].toString()) : null,
          nextCursorId: data['next_cursor_id'] != null ? (data['next_cursor_id'] as num).toInt() : null,
          hasMore: data['has_more'] == true,
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(loadingMore: false);
      return false;
    }
  }

  // 3. 실시간 메시지 수신: 리스트의 맨 앞(0번)에 추가
  void appendMessage(ChatMessage message) {
    final detail = state.detail;
    if (detail == null) return;

    // [핵심] 새 메시지는 0번 인덱스로 넣어야 reverse: true 리스트의 맨 아래(최신)에 바로 뜹니다.
    final updatedMessages = [message, ...detail.messages];

    state = state.copyWith(
        detail: detail.copyWith(messages: updatedMessages)
    );
  }
}

final chatRoomDetailProvider = StateNotifierProvider.family<
    ChatRoomDetailNotifier,
    ChatRoomDetailState,
    int>((ref, roomId) {
  return ChatRoomDetailNotifier(ref, roomId);
});
