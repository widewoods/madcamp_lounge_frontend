import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';

import '../../../../api_client.dart';

class PartyDescription extends ConsumerStatefulWidget {
  const PartyDescription({super.key, required this.party});

  final Party party;
  @override
  ConsumerState<PartyDescription> createState() => _PartyDescriptionState();
}

class _PartyDescriptionState extends ConsumerState<PartyDescription> {
  Future<void> _closeParty() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.patchJson(
      '/party/delete',
      body: {
        'party_id': widget.party.partyId,
      }
    );

    if(!mounted) return;

    if(res.statusCode == 200){
      Navigator.of(context).pop(widget.party.partyId);
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.statusCode}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color kPrimary = Theme.of(context).primaryColor;
    final Color infoBackgroundColor = Colors.grey.withValues(alpha: 0.09);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.party.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.party.category,
                    style: TextStyle(color: kPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (widget.party.content!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: infoBackgroundColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.black),
                      const SizedBox(width: 5),
                      Text(widget.party.content!),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              _infoRow(
                info: "일시",
                infoText: widget.party.time,
                icon: Icons.calendar_today_outlined,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 5),
              _infoRow(
                info: "장소",
                infoText: widget.party.locationText,
                icon: Icons.location_pin,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 5),
              _infoRow(
                info: "인원",
                infoText:
                    "${widget.party.currentCount} / ${widget.party.targetCount}명",
                icon: Icons.people_outline,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Icon(Icons.people_sharp),
                  const SizedBox(width: 10),
                  Text(
                    "참가자 (${widget.party.currentCount}명)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Expanded(
                    child: Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: IconButton(
                        //Todo: OnPressed - 나가기
                          onPressed: () {},
                          icon: Icon(Icons.logout_outlined),
                      ),
                    ),
                  )

                ],
              ),

              const SizedBox(height: 10),
              for (Map<String, dynamic> member in widget.party.members)
                _MemberProfile(infoBackgroundColor: infoBackgroundColor, kPrimary: kPrimary, member: member),

              const SizedBox(height: 10,),

              if(widget.party.isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                  onPressed: () {
                    _closeParty();
                  },
                  child: Text("파티 닫기"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberProfile extends StatelessWidget {
  const _MemberProfile({
    super.key,
    required this.infoBackgroundColor,
    required this.kPrimary,
    required this.member,
  });

  final Color infoBackgroundColor;
  final Color kPrimary;
  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: infoBackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary.withValues(alpha: 0.10),
            ),
            child: Align(
              alignment: AlignmentGeometry.center,
              child: Text(
                member['name'][0],
                style: TextStyle(
                  color: kPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    member['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),

                ),
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    member['class_section'],
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _infoRow extends StatelessWidget {
  const _infoRow({
    super.key,
    required this.info,
    required this.infoText,
    required this.icon,
    required this.kPrimary,
  });

  final String info;
  final String infoText;
  final IconData icon;
  final Color kPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 18),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Text(info, style: TextStyle(fontSize: 11)),
              ),
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Text(infoText, style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
