
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';

import '../../../../api_client.dart';
import '../../date_formatting.dart';
import '../../party_list_provider.dart';
import 'create_party_dialog.dart';

class PartyDescription extends ConsumerStatefulWidget {
  const PartyDescription({super.key, required this.party});

  final Party party;
  @override
  ConsumerState<PartyDescription> createState() => _PartyDescriptionState();
}

class _PartyDescriptionState extends ConsumerState<PartyDescription> {
  late Party _party;

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

  Future<void> _openCreatePartyDialog() async {
    final edited = await showDialog<Party>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CreatePartyDialog(initialParty: _party,),
    );

    if (edited != null) {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.patchJson(
          '/party/edit',
          body: {
            'party_id': edited.partyId,
            'title': edited.title,
            'appointment_time': edited.time,
            'category': edited.category,
            'content': edited.content,
            'place_name': edited.locationText,
            'target_count': edited.targetCount,
          }
      );

      if(!mounted) return;

      if(res.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파티 수정됨')),
        );
        ref.invalidate(partyListProvider);
        setState(() {
          _party = edited;
        });
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.statusCode}')),
        );
      }

      setState(() {});
    }
  }

  Future<void> _quitParty() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.delete(
        '/party/exit',
        body: {
          'party_id': widget.party.partyId.toString(),
        }
    );

    if(!mounted) return;

    if(res.statusCode == 200){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파티에서 탈퇴했습니다.'), duration: Duration(seconds: 1),),
      );
    }
    else if(res.statusCode == 409){
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방장은 탈퇴할 수 없습니다.'), duration: Duration(seconds: 1),),
      );
    }
    else{
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파티 탈퇴 실패 에러: ${res.statusCode}')),
      );
    }
    ref.invalidate(partyListProvider);
  }

  @override @override
  void initState() {
    super.initState();
    _party = widget.party;
  }


  @override
  Widget build(BuildContext context) {
    final formattedTime = formatIsoKorean(parseIso(_party.time));
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _party.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if(_party.isHost)
                    IconButton(
                        onPressed: () {
                          _openCreatePartyDialog();
                        },
                        icon: Icon(Icons.edit)),
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 2),

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
                    _party.category,
                    style: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_party.content != null)
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF757575), size: 18,),
                    const SizedBox(width: 5),
                    Expanded(child: Text(_party.content!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,), maxLines: null,)),
                  ],
                ),

              const SizedBox(height: 10),

              _infoRow(
                info: "일시",
                infoText: formattedTime,
                icon: Icons.calendar_today_outlined,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 5),
              _infoRow(
                info: "장소",
                infoText: _party.locationText,
                icon: Icons.location_pin,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 5),
              _infoRow(
                info: "인원",
                infoText:
                    "${_party.currentCount} / ${_party.targetCount}명",
                icon: Icons.people_outline,
                kPrimary: kPrimary,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Icon(Icons.people_sharp),
                  const SizedBox(width: 10),
                  Text(
                    "참가자 (${_party.currentCount}명)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  if (_party.joined)
                    Expanded(
                      child: Align(
                        alignment: AlignmentGeometry.centerRight,
                        child: IconButton(
                            onPressed: _quitParty,
                            icon: Icon(Icons.logout_outlined),
                        ),
                      ),
                    )

                ],
              ),

              const SizedBox(height: 10),
              SingleChildScrollView(
                child: Column(
                  children: [
                    for (Map<String, dynamic> member in _party.members)
                      _MemberProfile(infoBackgroundColor: infoBackgroundColor, kPrimary: kPrimary, member: member),
                  ],
                ),
              ),


              const SizedBox(height: 10,),

              if(_party.isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red
                  ),
                  onPressed: () {
                    _closeParty();
                  },
                  child: Text("파티 삭제"),
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
    required this.infoBackgroundColor,
    required this.kPrimary,
    required this.member,
  });

  final Color infoBackgroundColor;
  final Color kPrimary;
  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
        ),
        const SizedBox(height: 4)
      ],
    );
  }
}

class _infoRow extends StatelessWidget {
  const _infoRow({
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
