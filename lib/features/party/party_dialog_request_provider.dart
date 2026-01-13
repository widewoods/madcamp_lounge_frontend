// lib/party/party_dialog_request_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../recommend/model/place.dart';

final createPartyDialogRequestProvider =
StateProvider<Place?>((ref) => null, name: 'createPartyDialogRequestProvider');
