import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:madcamp_lounge/pages/login.dart';
import 'package:madcamp_lounge/state/auth_state.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _storage = const FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    ref.read(accessTokenProvider.notifier).state = null;
    await _storage.delete(key: 'refreshToken');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        child: FilledButton(
          onPressed: () => _logout(context),
          child: const Text('로그아웃'),
        ),
      ),
    );
  }
}
