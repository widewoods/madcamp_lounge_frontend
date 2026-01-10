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

  void _onJoin() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("참가하기")),
      );
  }

  Future<void> _openCreatePartyDialog() async {
    final created = await showDialog<Party>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CreatePartyDialog(),
    );

    if (created != null) {
      setState(() {
        _parties.insert(0, created);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: 
        const Size.fromHeight(kToolbarHeight),
        child: PartyAppBar(onClick: _openCreatePartyDialog,),
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
              onJoin: _onJoin,
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

class CreatePartyDialog extends StatefulWidget {
  const CreatePartyDialog({super.key});

  @override
  State<CreatePartyDialog> createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> {
  static const kPrimary = Color(0xFF4C46E5);

  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  int _maxPeople = 6;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "파티 만들기",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              const Text("제목", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: _dec("예: 보드게임 같이 하실 분!"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              const Text("카테고리", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryCtrl,
                decoration: _dec("예: 보드게임"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              const Text("시간", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _timeCtrl,
                decoration: _dec("예: 오늘 오후 7시"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              const Text("장소", style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationCtrl,
                decoration: _dec("예: 강남 보드게임카페"),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 14),

              // 인원 선택
              Row(
                children: [
                  const Text("최대 인원", style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: _maxPeople > 2
                        ? () => setState(() => _maxPeople--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$_maxPeople명", style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(
                    onPressed: _maxPeople < 20
                        ? () => setState(() => _maxPeople++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("취소"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      child: const Text("만들기"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (title.isEmpty || category.isEmpty || time.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요")),
      );
      return;
    }

    final party = Party(
      title: title,
      category: category,
      timeText: time,
      locationText: location,
      current: 1,
      max: _maxPeople,
      imageUrl:
      "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
    );

    Navigator.pop(context, party);
  }
}
