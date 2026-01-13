import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_message.dart';
import 'package:madcamp_lounge/features/chatting/state/chat_room_detail_state.dart';
import 'package:madcamp_lounge/state/auth_state.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.roomId});

  final int roomId;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  static const _primary = Color(0xFF4C46E5);

  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  StompClient? _stompClient;
  bool _stompConnected = false;
  int? _userId;
  ProviderSubscription<ChatRoomDetailState>? _detailSub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatRoomDetailProvider(widget.roomId).notifier).loadInitial();
    });
    _detailSub = ref.listenManual<ChatRoomDetailState>(
      chatRoomDetailProvider(widget.roomId),
      (previous, next) {
        if (previous?.detail == null && next.detail != null) {
          final messages = next.detail!.messages;
          if (messages.isNotEmpty) {
            _sendRead(messages.last.messageId);
            _scrollToBottom();
          }
        }
      },
    );
    _loadUserId();
    _scrollController.addListener(_handleScroll);
    _connectStomp();
  }

  Future<void> _loadUserId() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/profile/me');
    if (!mounted) return;
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      setState(() {
        _userId = (data['id'] as num).toInt();
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 80) {
      ref.read(chatRoomDetailProvider(widget.roomId).notifier).loadMore();
    }
  }

  void _connectStomp() {
    final accessToken = ref.read(accessTokenProvider);
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    const wsUrl = 'ws://34.50.62.91:8080/ws';
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        stompConnectHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    _stompConnected = true;
    _stompClient?.subscribe(
      destination: '/topic/rooms/${widget.roomId}',
      callback: (message) {
        if (message.body == null) return;
        final data = jsonDecode(message.body!) as Map<String, dynamic>;
        final chatMessage = ChatMessage.fromJson(data);
        ref.read(chatRoomDetailProvider(widget.roomId).notifier).appendMessage(chatMessage);
        _sendRead(chatMessage.messageId);
        _scrollToBottom();
      },
    );
  }

  void _onStompError(StompFrame frame) {
    _stompConnected = false;
  }

  void _onWebSocketError(dynamic error) {
    _stompConnected = false;
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty || !_stompConnected) return;

    _stompClient?.send(
      destination: '/app/rooms/${widget.roomId}',
      body: jsonEncode({'content': text}),
    );
    _inputController.clear();
  }

  void _sendRead(int lastMessageId) {
    if (!_stompConnected) return;
    _stompClient?.send(
      destination: '/app/rooms/${widget.roomId}/read',
      body: jsonEncode({'last_message_id': lastMessageId}),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _detailSub?.close();
    _scrollController.dispose();
    _inputController.dispose();
    _stompClient?.deactivate();
    super.dispose();
  }

  Widget _buildBubble(ChatMessage message) {
    final isMine = _userId != null && message.senderId == _userId;
    final bubbleColor = isMine ? _primary : const Color(0xFFF0F2F8);
    final textColor = isMine ? Colors.white : const Color(0xFF111827);
    final align = isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomDetailProvider(widget.roomId));
    final detail = state.detail;
    final title = detail?.partyTitle ?? '채팅방 ${widget.roomId}';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Color(0xFF6B7280)),
                          ),
                        )
                      : detail == null
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              itemCount: detail.messages.length +
                                  (state.loadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (state.loadingMore) {
                                  if (index == 0) {
                                    return const Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Center(
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return _buildBubble(detail.messages[index - 1]);
                                }
                                return _buildBubble(detail.messages[index]);
                              },
                            ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                        filled: true,
                        fillColor: const Color(0xFFF4F5FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sendMessage,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
