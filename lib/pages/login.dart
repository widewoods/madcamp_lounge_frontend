import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    const borderColor = Color(0xFFD6D9E6);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9AA0AE)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4C46E5), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4C46E5);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              Color(0xFFE8F0FF),
              Color(0xFFF4F7FF),
            ],
          ),
        ),
        child: SafeArea(
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
                          decoration: _inputDecoration("아이디를 입력하세요"),
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
                          decoration: _inputDecoration("비밀번호를 입력하세요"),
                          onSubmitted: (_) => _login(context),
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
      ),
    );
  }

  void _login(BuildContext context) {
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("데모 로그인: id=$id, pw 길이=${pw.length}"),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class FirstLoginText extends StatelessWidget {
  const FirstLoginText({
    super.key,
  });

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
  const SubtitleText({
    super.key,
  });

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
  const TitleText({
    super.key,
  });

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
  const LoginIcon({
    super.key,
    required this.primary,
  });

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
        child: const Icon(
          Icons.login_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}