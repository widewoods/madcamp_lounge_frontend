import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
import 'package:madcamp_lounge/features/party/ui/dialogs/create_party_dialog.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_appbar.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_card.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            ),
          );
        },
      ),
    );
  }
}


