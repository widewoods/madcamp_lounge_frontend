import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/party/party_list_provider.dart';
import 'package:madcamp_lounge/gradient_button.dart';
import 'package:madcamp_lounge/theme.dart';

import '../../../../pages/main_page.dart';
import '../../date_formatting.dart';
import '../../model/party.dart';

class PartyCard extends StatefulWidget {
  const PartyCard({
    super.key,
    required this.party,
    required this.onTap,
  });

  final Party party;
  final VoidCallback onTap;

  @override
  State<PartyCard> createState() => _PartyCardState();
}

class _PartyCardState extends State<PartyCard> {

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final formattedTime = formatIsoKorean(parseIso(widget.party.time));
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000).withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 3),
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
                      width: 110,
                      height: 110,
                      child: Image.network(
                        widget.party.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.party.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // 카테고리
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: RadialGradient(
                                center: AlignmentGeometry.topLeft,
                                radius: 1.1,
                                colors: gradientColor,
                              )
                            ),
                            child: Text(
                              widget.party.category,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        _InfoRow(icon: Icons.access_time, text: formattedTime),
                        const SizedBox(height: 6),
                        _InfoRow(icon: Icons.location_on, text: widget.party.locationText),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.people,
                          text: "${widget.party.currentCount} / ${widget.party.targetCount}명",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              JoinButton(joined: widget.party.joined, party: widget.party),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinButton extends ConsumerStatefulWidget {

  const JoinButton({
    super.key,
    required this.joined,
    required this.party,
  });

  final bool joined;
  final Party party;

  @override
  ConsumerState<JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends ConsumerState<JoinButton> {
  Future<void> _onJoin() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.postJson(
        '/party/join',
        body: {
          'party_id': widget.party.partyId,
        }
    );

    if(!mounted) return;

    if(res.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파티에 참가했습니다.'), duration: Duration(seconds: 1),),
      );
    }
    else if(res.statusCode == 409){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 참가한 상태입니다.'), duration: Duration(seconds: 1),),
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.statusCode}')),
      );
    }
    ref.invalidate(partyListProvider);
  }

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.party.joined;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: GradientButton(
        onPressed: disabled ? null : _onJoin,
        text: "참가하기",
        colors: gradientColor
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

