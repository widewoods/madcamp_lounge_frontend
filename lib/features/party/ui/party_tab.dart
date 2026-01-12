import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/create_party_dialog.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_appbar.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';

class PartyTab extends ConsumerStatefulWidget {
  const PartyTab({super.key});

  @override
  ConsumerState<PartyTab> createState() => _PartyTabState();
}

class _PartyTabState extends ConsumerState<PartyTab> {
  List<Party> _parties = [
    Party(
      title: "보드게임 같이 하실 분!",
      category: "보드게임",
      timeText: "오늘 오후 7시",
      locationText: "강남 보드게임카페",
      currentCount: 3,
      targetCount: 6,
      imageUrl:
      "https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=400&q=80",
    ),
    Party(
      title: "볼링 치러 가요~",
      category: "볼링",
      timeText: "내일 오후 3시",
      locationText: "신촌 볼링장",
      currentCount: 2,
      targetCount: 4,
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

  Future<void> _getPartyList() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/party/list');

    if(!mounted) return;

    if(res.statusCode == 200){
      final data = jsonDecode(res.body);
      setState(() {
        _parties = data.map((e) => Party.fromJson(e)).toList();
      });

    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.statusCode}')),
      );
    }
  }

  @override
  void initState(){
    super.initState();
    _getPartyList();
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


