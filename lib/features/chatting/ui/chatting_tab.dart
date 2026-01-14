import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_room.dart';
import 'package:madcamp_lounge/features/chatting/state/chatting_state.dart';
import 'package:madcamp_lounge/features/chatting/ui/chat_room_page.dart';
import 'package:madcamp_lounge/theme.dart';

class ChattingTab extends ConsumerStatefulWidget {
  const ChattingTab({super.key});

  @override
  ConsumerState<ChattingTab> createState() => _ChattingTabState();
}

class _ChattingTabState extends ConsumerState<ChattingTab> {
  ProviderSubscription<int>? _refreshSub;
  StompClient? _stompClient;

  @override
  void initState() {
    super.initState();
    _refreshSub = ref.listenManual<int>(
      chatTabRefreshTriggerProvider,
      (_, __) {
        if (!mounted) return;
        ref.refresh(chatRoomListProvider);
      },
    );
    Future.microtask(() {
      if (!mounted) return;
      ref.refresh(chatRoomListProvider);
    });
    _connectStomp();
  }

  @override
  void dispose() {
    _refreshSub?.close();
    _stompClient?.deactivate();
    super.dispose();
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
        onConnect: (_) {
          _stompClient?.subscribe(
            destination: '/topic/rooms',
            callback: (_) {
              if (!mounted) return;
              ref.refresh(chatRoomListProvider);
            },
          );
        },
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

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return '${value.month.toString().padLeft(2, '0')}.'
        '${(value.day).toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _openChatRoom(
    BuildContext context,
    ChatRoom room,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(roomId: room.roomId),
      ),
    );
    ref.invalidate(chatRoomListProvider);
  }

  Widget _buildRoomTile(BuildContext context, ChatRoom room) {
    final title = (room.partyTitle != null && room.partyTitle!.isNotEmpty)
        ? room.partyTitle!
        : (room.otherName != null && room.otherName!.isNotEmpty)
            ? room.otherName!
            : (room.partyId == null
                ? '채팅방 #${room.roomId}'
                : '파티 #${room.partyId}');
    final lastMessageAt = _formatDate(room.lastMessageAt);
    final lastMessageContent = (room.lastMessageContent ?? '').trim();
    final hasLastMessage = lastMessageContent.isNotEmpty || lastMessageAt.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openChatRoom(context, room),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(14),
          // boxShadow: [
          //   BoxShadow(
          //     color: Color(0x14000000).withValues(alpha: 0.1),
          //     blurRadius: 4,
          //     offset: Offset(0, 3),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  colors: [
                    kPrimary.withValues(alpha: 0.5),
                    kPrimary.withValues(alpha: 0.8),
                  ],
                  radius: 1.1

                )
              ),
              padding: EdgeInsets.only(top: 2.0),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Text(
                        lastMessageAt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],

                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!hasLastMessage)
                        Expanded(
                          child: const Text(
                            '최근 메시지 없음',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: Text(
                            lastMessageContent.isEmpty ? '메시지 없음' : lastMessageContent,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (room.unreadCount > 0) _buildUnreadBadge(room.unreadCount),
                    ],
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(chatRoomListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: rooms.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              '채팅방 목록을 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          data: (list) => RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(chatRoomListProvider.future);
            },
            child: list.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          '참여 중인 채팅방이 없습니다.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) =>
                        _buildRoomTile(context, list[index]),
                  ),
          ),
        ),
      ),
    );
  }
}
