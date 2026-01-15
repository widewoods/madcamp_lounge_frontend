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
  final Map<int, int> lastReadByUser;

  const ChatRoomDetailState({
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.detail,
    required this.lastReadByUser,
  });

  ChatRoomDetailState copyWith({
    bool? loading,
    bool? loadingMore,
    String? error,
    ChatRoomDetail? detail,
    Map<int, int>? lastReadByUser,
  }) {
    return ChatRoomDetailState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: error,
      detail: detail ?? this.detail,
      lastReadByUser: lastReadByUser ?? this.lastReadByUser,
    );
  }

  static ChatRoomDetailState initial() {
    return const ChatRoomDetailState(
      loading: true,
      loadingMore: false,
      error: null,
      detail: null,
      lastReadByUser: {},
    );
  }
}

class ChatRoomDetailNotifier extends StateNotifier<ChatRoomDetailState> {
  ChatRoomDetailNotifier(this._ref, this._roomId) : super(ChatRoomDetailState.initial());

  final Ref _ref;
  final int _roomId;

  // 1. 초기 로드: 모든 버그를 잡는 핵심 초기화 로직
  Future<void> loadInitial(int myId) async {
    state = state.copyWith(loading: true, error: null);
    final apiClient = _ref.read(apiClientProvider);
    final res = await apiClient.get('/chat/chatroom?room_id=$_roomId');

    if (res.statusCode != 200) {
      state = state.copyWith(loading: false, error: '데이터를 불러오지 못했습니다.');
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

    // [버그 해결 1] 내가 들어왔으므로, 기존 메시지 중 내가 안 보낸 것은 즉시 -1 처리 (Case 2 해결)
    final processedMessages = orderedMessages.map((m) {
      if (m.senderId != myId && m.unreadCount > 0) {
        return m.copyWith(unreadCount: (m.unreadCount - 1).clamp(0, 999));
      }
      return m;
    }).toList();

    final maxMessageId = processedMessages.isEmpty ? 0 : processedMessages.first.messageId;

    // [버그 해결 2] 모든 인원의 지점을 현재 시점으로 고정하여 과거 메시지 중복 차감 방지 (Case 1, 3, 5 해결)
    final initialMarkers = {
      for (final member in detail.members) member.userId: maxMessageId
    };

    state = state.copyWith(
      loading: false,
      detail: detail.copyWith(messages: processedMessages),
      lastReadByUser: initialMarkers,
      error: null,
    );
  }

  // 2. 실시간 메시지 수신
  void appendMessage(ChatMessage message, int myId) {
    final detail = state.detail;
    if (detail == null) return;

    // [버그 해결 3] 실시간으로 오는 남의 메시지는 내가 즉시 읽은 것이므로 -1 처리 (새로운 버그 해결)
    var displayMessage = message;
    if (displayMessage.senderId != myId && displayMessage.unreadCount > 0) {
      displayMessage = displayMessage.copyWith(unreadCount: (displayMessage.unreadCount - 1).clamp(0, 999));
    }

    // 발신자의 위치 정보도 즉시 업데이트
    final updatedMarkers = {
      ...state.lastReadByUser,
      message.senderId: message.messageId,
    };

    state = state.copyWith(
      detail: detail.copyWith(messages: [displayMessage, ...detail.messages]),
      lastReadByUser: updatedMarkers,
    );
  }

  // 3. 읽음 신호 처리
  void applyReadRange(int readerId, int lastMessageId) {
    final detail = state.detail;
    if (detail == null) return;

    final previousReadId = state.lastReadByUser[readerId] ?? 0;
    if (lastMessageId <= previousReadId) return;

    final updatedMessages = detail.messages.map((message) {
      // 새로운 범위 내에 있고, 읽은 사람이 발신자가 아닐 때만 차감
      if (message.messageId <= lastMessageId &&
          message.messageId > previousReadId &&
          message.senderId != readerId &&
          message.unreadCount > 0) {
        return message.copyWith(unreadCount: (message.unreadCount - 1).clamp(0, 999));
      }
      return message;
    }).toList();

    state = state.copyWith(
      detail: detail.copyWith(messages: updatedMessages),
      lastReadByUser: {
        ...state.lastReadByUser,
        readerId: lastMessageId,
      },
    );
  }

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
      if (res.statusCode != 200) throw Exception();
      final data = jsonDecode(res.body);
      final List<dynamic> messagesJson = data['messages'];
      final olderMessages = messagesJson.map((m) => ChatMessage.fromJson(m)).toList()
        ..sort((a, b) {
          final timeCompare = b.sentAt.compareTo(a.sentAt);
          if (timeCompare != 0) return timeCompare;
          return b.messageId.compareTo(a.messageId);
        });

      state = state.copyWith(
        loadingMore: false,
        detail: detail.copyWith(
          messages: [...detail.messages, ...olderMessages],
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
}

final chatRoomDetailProvider = StateNotifierProvider.family<
    ChatRoomDetailNotifier,
    ChatRoomDetailState,
    int>((ref, roomId) {
  return ChatRoomDetailNotifier(ref, roomId);
});