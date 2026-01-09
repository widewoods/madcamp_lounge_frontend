import 'package:flutter/material.dart';

class PartyTab extends StatefulWidget {
  const PartyTab({super.key});

  @override
  State<PartyTab> createState() => _PartyTabState();
}

class _PartyTabState extends State<PartyTab> {
  final List<Party> _parties = [
    Party(
      title: "보드게임 같이 하실 분!",
      category: "보드게임",
      timeText: "오늘 오후 7시",
      locationText: "강남 보드게임카페",
      current: 3,
      max: 6,
      imageUrl:
      "https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=400&q=80",
    ),
    Party(
      title: "볼링 치러 가요~",
      category: "볼링",
      timeText: "내일 오후 3시",
      locationText: "신촌 볼링장",
      current: 2,
      max: 4,
      imageUrl:
      "https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=400&q=80",
    ),
  ];

  //Todo: 파티만들기 버튼 기능 구현
  /// 파티 만들기 눌렀을 때 팝업이 뜨면서
  /// 필수: 제목, 카테고리, 시간, 장소, 최대 인원 입력
  /// 선택: 사진 업로드
  void _addDemoParty() {
    setState(() {
      _parties.insert(
        0,
        Party(
          title: "새 파티가 생성됐어요!",
          category: "모임",
          timeText: "모레 오후 6시",
          locationText: "카이스트 근처",
          current: 1,
          max: 5,
          imageUrl:
          "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: 
        const Size.fromHeight(kToolbarHeight),
        child: PartyAppBar(onClick: _addDemoParty,),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _parties.length,
        itemBuilder: (context, index) {
          final party = _parties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PartyCard(
              party: party,
              onToggleLike: () {
                setState(() {
                  party.isLiked = !party.isLiked;
                });
              },
              onJoin: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("참가하기: ${party.title}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PartyAppBar extends StatelessWidget {
  const PartyAppBar({
    required this.onClick,
    super.key,
  });

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "파티원 구하기",
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onClick,
          icon: Icon(Icons.add),
          label: const Text("파티 만들기"),
        )
      ],
    );
  }
}

class Party {
  Party({
    required this.title,
    required this.category,
    required this.timeText,
    required this.locationText,
    required this.current,
    required this.max,
    required this.imageUrl,
    this.isLiked = false,
  });

  final String title;
  final String category;
  final String timeText;
  final String locationText;
  final int current;
  final int max;
  final String imageUrl;
  bool isLiked;
}

class PartyCard extends StatelessWidget {
  const PartyCard({
    super.key,
    required this.party,
    required this.onToggleLike,
    required this.onJoin,
  });

  final Party party;
  final VoidCallback onToggleLike;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
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