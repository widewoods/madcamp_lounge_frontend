import 'package:flutter/material.dart';

import '../../model/party.dart';

class PartyCard extends StatelessWidget {
  const PartyCard({
    super.key,
    required this.party,
    required this.onToggleLike,
  });

  final Party party;
  final VoidCallback onToggleLike;

  @override
  Widget build(BuildContext context) {
    void onJoin() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("참가하기")),
      );
    }

    const primary = Color(0xFF4C46E5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 (왼쪽)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.network(
                      party.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 텍스트 영역 (오른쪽)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 + 하트
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              party.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onToggleLike,
                            icon: Icon(
                              party.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: party.isLiked
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // 카테고리(파란 링크 느낌)
                      Text(
                        party.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _InfoRow(icon: Icons.access_time, text: party.timeText),
                      const SizedBox(height: 6),
                      _InfoRow(icon: Icons.location_on, text: party.locationText),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.people,
                        text: "${party.current} / ${party.max}명",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 참가하기 버튼 (아래 가로로 길게)
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                child: const Text("참가하기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

