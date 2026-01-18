import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/party_list_provider.dart';
import 'package:madcamp_lounge/pages/main_page.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/state/auth_state.dart';

import '../theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends ConsumerState<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _storage = FlutterSecureStorage();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = kPrimary;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final cardWidth = maxW < 560 ? maxW * 0.9 : 520.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoginIcon(primary: primary),
                      const SizedBox(height: 16),

                      TitleText(),
                      const SizedBox(height: 8),

                      SubtitleText(),
                      const SizedBox(height: 26),

                      //Id field
                      const Text(
                        "아이디",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _idCtrl,
                        textInputAction: TextInputAction.next,
                        enableInteractiveSelection: false,
                        decoration: inputDecorationWithHint("아이디를 입력하세요"),
                      ),
                      const SizedBox(height: 18),

                      // Password field
                      const Text(
                        "비밀번호",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _pwCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: inputDecorationWithHint("비밀번호를 입력하세요"),
                        onSubmitted: (_) => _login(context),
                      ),
                      const SizedBox(height: 20),

                      // Login button
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          style:Theme.of(context).filledButtonTheme.style,
                          onPressed: () => _login(context),
                          child: const Text("로그인"),
                        ),
                      ),

                      const SizedBox(height: 18),
                      FirstLoginText(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text;

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("아이디와 비밀번호를 입력하세요."),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.postJson(
      '/auth/login',
      body: {'loginId': id, 'password': pw},
      useAuth: false,
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      ref.read(accessTokenProvider.notifier).state = accessToken;
      ref.invalidate(userIdProvider);
      ref.invalidate(partyListProvider);
      await _storage.write(key: 'refreshToken', value: refreshToken);

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      if (data['loginId'] == pw) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainPage(
              startIndex: 3,
              showPasswordChangeDialog: true,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainPage()));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text("로그인 실패")));
    }
  }
}

class FirstLoginText extends StatelessWidget {
  const FirstLoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "처음 로그인하시나요? 비밀번호 변경이 필요합니다.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class SubtitleText extends StatelessWidget {
  const SubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "함께 즐기는 우리들의 공간",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "몰캠 라운지",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
        color: Color(0xFF111827),
      ),
    );
  }
}

class LoginIcon extends StatelessWidget {
  const LoginIcon({super.key, required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.login_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
