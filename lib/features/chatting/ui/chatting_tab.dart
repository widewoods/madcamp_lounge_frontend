import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/chatting/model/chat_room.dart';
import 'package:madcamp_lounge/features/chatting/state/chatting_state.dart';
import 'package:madcamp_lounge/features/chatting/ui/chat_room_page.dart';

class ChattingTab extends ConsumerWidget {
  const ChattingTab({super.key});

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return '${value.month.toString().padLeft(2, '0')}.'
        '${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4C46E5),
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
    WidgetRef ref,
    ChatRoom room,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(roomId: room.roomId),
      ),
    );
    ref.invalidate(chatRoomListProvider);
  }

  Widget _buildRoomTile(BuildContext context, WidgetRef ref, ChatRoom room) {
    final title = (room.partyTitle != null && room.partyTitle!.isNotEmpty)
        ? room.partyTitle!
        : (room.partyId == null
            ? '채팅방 #${room.roomId}'
            : '파티 #${room.partyId}');
    final lastMessageAt = _formatDate(room.lastMessageAt);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openChatRoom(context, ref, room),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE6ECFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF4C46E5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessageAt.isEmpty ? '최근 메시지 없음' : lastMessageAt,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (room.unreadCount > 0) _buildUnreadBadge(room.unreadCount),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildRoomTile(context, ref, list[index]),
                  ),
          ),
        ),
      ),
    );
  }
}
