import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api_client.dart';
import 'model/party.dart';

final partyListProvider = FutureProvider<List<Party>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final res = await apiClient.get('/party/list');

  final userId = await ref.watch(userIdProvider.future);

  if(res.statusCode == 200){
    final data = jsonDecode(res.body);
    return List<Party>.from(data.where((p) => p['status'] == "OPEN").map((e) => Party.fromJson(e, userId)));
  } else{
    throw Exception("Failed to get partyList: ${res.statusCode}");
    return <Party>[];
  }
});

final userIdProvider = FutureProvider<int>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final res = await apiClient.get('/profile/me');

  if(res.statusCode == 200){
    final data = jsonDecode(res.body);

    return data['id'] as int;

  } else{
    debugPrint("Failed to get userId: ${res.statusCode}");
    throw Exception("Failed to get userId: ${res.statusCode}");
  }
});