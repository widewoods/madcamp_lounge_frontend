import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
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

  ProviderSubscription<int>? _sub;

  List<Party> _parties = [];

  int _userId = -1;

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

        await  _getPartyList();
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.statusCode}')),
        );
      }

      setState(() {});
    }
  }

  Future<void> _getPartyList() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/party/list');

    if(!mounted) return;

    if(res.statusCode == 200){
      final data = jsonDecode(res.body);
      setState(() {
        _parties = List<Party>.from(data.where((p) => p['status'] == "OPEN").map((e) => Party.fromJson(e, _userId == e['host_id'])));
        for(Party p in _parties){
          final memberList = p.members.map((e) => e['user_id']).toList();
          p.joined = memberList.contains(_userId);
        }
      });

    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.statusCode}')),
      );
    }
  }

  Future<void> _getUserId() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/profile/me');

    if(!mounted) return;

    if(res.statusCode == 200){
      final data = jsonDecode(res.body);
      setState(() {
        _userId = data['id'] as int;
      });

    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get userId: ${res.statusCode}')),
      );
    }
  }

  Future<void> _openPartyDescription(Party party) async {
    final closedPartyId = await showDialog<int>(
      context: context,
      builder: (_) => PartyDescription(party: party),
    );

    if (!mounted) return;

    if (closedPartyId != null) {
      setState(() {
        _parties.removeWhere((p) => p.partyId == closedPartyId);
      });
    }
  }

  @override
  void initState(){
    super.initState();
    _getUserId();
    _getPartyList();

    _sub = ref.listenManual<int>(bottomNavIndexProvider, (prev, next) {
      if (next == 0 && prev != 0) {
        _getPartyList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<Place?>(createPartyDialogRequestProvider, (prev, next) {
      if(next == null) return;
      debugPrint('Listener fired event: $next');

      Place initialPlace = ref.read(createPartyDialogRequestProvider.notifier).state!;
      ref.read(createPartyDialogRequestProvider.notifier).state = null;
      _openCreatePartyDialog(initialPlace: initialPlace.name, initialCategory: initialPlace.categoryId);
    });

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
              onTap: () => _openPartyDescription(party),
            ),
          );
        },
      ),
    );
  }
}


