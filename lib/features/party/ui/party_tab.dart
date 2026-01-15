import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
import 'package:madcamp_lounge/features/party/party_list_provider.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/create_party_dialog.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_appbar.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/party_description.dart';

import '../../../pages/main_page.dart';
import '../../recommend/model/place.dart';
import '../party_dialog_request_provider.dart';

class PartyTab extends ConsumerStatefulWidget {
  const PartyTab({super.key});

  @override
  ConsumerState<PartyTab> createState() => _PartyTabState();
}

class _PartyTabState extends ConsumerState<PartyTab> {

  Future<void> _openCreatePartyDialog({
    String? initialPlace,
    String? initialCategory,
  }) async {
    final created = await showDialog<Party>(
      context: context,
      barrierDismissible: true,
      builder: (_) => CreatePartyDialog(initialPlace: initialPlace, initialCategory: initialCategory,),
    );

    if (created != null) {
      final apiClient = ref.read(apiClientProvider);
      final res = await apiClient.postJson(
        '/party/create',
        body: {
          'title': created.title,
          'category': created.category,
          'content': created.content,
          'appointment_time': created.time,
          'place_name': created.locationText,
          'target_count': created.targetCount,
        }
      );

      if(!mounted) return;

      if(res.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파티 생성됨')),
        );
        created.partyId = jsonDecode(res.body)['id'] as int;

        ref.invalidate(partyListProvider);
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.statusCode}')),
        );
      }

      setState(() {});
    }
  }

  Future<List<Party>> _getPartyList() async {
    return await ref.read(partyListProvider.future);
  }

  Future<int> _getUserId() async {
    return await ref.read(userIdProvider.future);
  }

  Future<void> _openPartyDescription(Party party) async {
    final closedPartyId = await showDialog<int>(
      context: context,
      builder: (_) => PartyDescription(party: party),
    );

    if (!mounted) return;

    if (closedPartyId != null) {
      ref.invalidate(partyListProvider);
    }
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Place?>(createPartyDialogRequestProvider, (prev, next) {
      if(next == null) return;
      Place initialPlace = ref.read(createPartyDialogRequestProvider.notifier).state!;
      ref.read(createPartyDialogRequestProvider.notifier).state = null;
      _openCreatePartyDialog(initialPlace: initialPlace.name, initialCategory: initialPlace.categoryId);
    });

    final partyAsync = ref.watch(partyListProvider);


    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(preferredSize: 
        const Size.fromHeight(kToolbarHeight),
        child: PartyAppBar(onClick: _openCreatePartyDialog,),
      ),

      body: partyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('불러오기 실패: $e'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(partyListProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      data: (parties) =>
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: parties.length,
          itemBuilder: (context, index) {
            final party = parties[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: PartyCard(
                party: party,
                onTap: () => _openPartyDescription(party),
              ),
            );
          },
        ),
      )
    );
  }
}


