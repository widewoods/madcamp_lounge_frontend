import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_message.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_member.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_room_detail.dart';
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
  final Map<int, GlobalKey> _messageKeys = {};
  final _readMarkerKey = GlobalKey();
  StompClient? _stompClient;
  bool _stompConnected = false;
  bool _didInitialScroll = false;
  bool _allowLoadMore = false;
  bool _loadingMoreRequest = false;
  DateTime? _lastLoadMoreAt;
  int? _userId;
  int? _pendingReadMessageId;
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
            final lastMessageId = messages.first.messageId;
            if (_stompConnected) {
              _sendRead(lastMessageId);
            } else {
              _pendingReadMessageId = lastMessageId;
            }
            _scrollToInitialPosition(next.detail!);
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
    final position = _scrollController.position;
    final nearTop = position.extentAfter <= 120;
    final scrollingUp = position.userScrollDirection == ScrollDirection.reverse;
    if (nearTop && scrollingUp && !_loadingMoreRequest) {
      _loadMoreWithAnchor();
    }
  }

  Future<void> _loadMoreWithAnchor() async {
    if (_loadingMoreRequest) return;

    // 중복 호출 방지를 위한 시간 간격 체크
    final now = DateTime.now();
    if (_lastLoadMoreAt != null &&
        now.difference(_lastLoadMoreAt!) < const Duration(milliseconds: 500)) {
      return;
    }

    _loadingMoreRequest = true;
    _lastLoadMoreAt = now;

    // 단순히 호출만 하면 됩니다. Flutter가 위치를 지켜줍니다.
    await ref.read(chatRoomDetailProvider(widget.roomId).notifier).loadMore();

    if (mounted) {
      _loadingMoreRequest = false;
    }
  }

  void _connectStomp() {
    final accessToken = ref.read(accessTokenProvider);
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    const wsUrl = 'ws://10.0.2.2:8080/ws';
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
    _stompClient?.subscribe(
      destination: '/topic/rooms/${widget.roomId}/read',
      callback: (_) {},
    );
    if (_pendingReadMessageId != null) {
      _sendRead(_pendingReadMessageId!);
      _pendingReadMessageId = null;
    } else {
      final detail = ref.read(chatRoomDetailProvider(widget.roomId)).detail;
      if (detail != null && detail.messages.isNotEmpty) {
        _sendRead(detail.messages.first.messageId);
      }
    }
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
      final minExtent = _scrollController.position.minScrollExtent;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent == 0) {
        Future.microtask(_scrollToBottom);
        return;
      }
      _scrollController.jumpTo(minExtent);
      _allowLoadMore = true;
    });
  }

  void _scrollToInitialPosition(ChatRoomDetail detail) {
    if (_didInitialScroll) return;
    _didInitialScroll = true;
    _scrollToBottom();
  }

  void _scrollToReadMarker(int lastReadId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _readMarkerKey.currentContext;
      if (context == null) {
        _scrollToMessage(lastReadId);
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
      _allowLoadMore = true;
    });
  }

  void _scrollToMessage(int messageId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _messageKeys[messageId];
      final context = key?.currentContext;
      if (context == null) {
        _scrollToBottom();
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
      _allowLoadMore = true;
    });
  }

  void _showMembers(List<ChatMember> members) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 56),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              child: SafeArea(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '참여 멤버',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (members.isEmpty)
                        const Text(
                          '참여자가 없습니다.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        )
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: members.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6ECFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFF4C46E5),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          member.classSection,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    member.nickname,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _detailSub?.close();
    _scrollController.dispose();
    _inputController.dispose();
    _stompClient?.deactivate();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchProfile(int userId) async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/profile/$userId');
    if (res.statusCode != 200) {
      return null;
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _showProfileSheet(int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchProfile(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data;
              if (data == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '프로필을 불러오지 못했습니다.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                );
              }
              final nickname = data['nickname']?.toString() ?? '';
              final classSection = data['class_section']?.toString() ?? '';
              final mbti = data['mbti']?.toString() ?? '';
              final hobby = data['hobby']?.toString() ?? '';
              final introduction = data['introduction']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6ECFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF4C46E5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            nickname.isEmpty ? '프로필' : nickname,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProfileRow('분반', classSection),
                    _buildProfileRow('MBTI', mbti),
                    _buildProfileRow('취미', hobby),
                    _buildProfileRow('소개', introduction),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message, {String? senderName}) {
    final isMine = _userId != null && message.senderId == _userId;
    final bubbleColor = isMine ? _primary : const Color(0xFFF0F2F8);
    final textColor = isMine ? Colors.white : const Color(0xFF111827);

    String _formatTime(DateTime value) {
      return '${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}';
    }

    final bubble = Container(
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
    );

    if (isMine) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(message.sentAt),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9AA0AE),
              ),
            ),
            const SizedBox(width: 6),
            bubble,
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showProfileSheet(message.senderId),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 6),
              decoration: const BoxDecoration(
                color: Color(0xFFE6ECFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: Color(0xFF4C46E5),
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (senderName != null && senderName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(child: bubble),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(message.sentAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA0AE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    ChatRoomDetail detail,
    Map<int, String> memberNameById,
    bool loadingMore,
  ) {
    // 최신순으로 정렬된 메시지 리스트 (index 0이 가장 최신)
    final messages = detail.messages;

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // 필수: 하단이 시작점
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        // reverse: true 이므로 위쪽으로 갈수록 index가 커짐
        return _buildBubble(
          message,
          senderName: memberNameById[message.senderId],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomDetailProvider(widget.roomId));
    final detail = state.detail;
    final baseTitle = detail?.partyTitle ?? '채팅방 ${widget.roomId}';
    final memberCount = detail?.members.length ?? 0;
    final memberNameById = detail == null
        ? const <int, String>{}
        : {
            for (final member in detail.members) member.userId: member.name,
          };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                baseTitle,
                style: const TextStyle(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: detail == null
                  ? null
                  : () => _showMembers(detail.members),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 28,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$memberCount',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
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
                            : _buildMessageList(
                                detail,
                                memberNameById,
                                state.loadingMore,
                              ),
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
