import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/pages/login.dart';
import 'package:madcamp_lounge/pages/main_page.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  late final Future<bool> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<bool> _bootstrap() async {
    final apiClient = ref.read(apiClientProvider);
    return apiClient.refreshSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isAuthed = snapshot.data == true;
        return isAuthed ? const MainPage() : const LoginPage();
      },
    );
  }
}
