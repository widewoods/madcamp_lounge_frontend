import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:madcamp_lounge/pages/login.dart';
import 'package:madcamp_lounge/state/auth_state.dart';

// class ProfileTab extends ConsumerStatefulWidget {
//   const ProfileTab({super.key});
//
//   @override
//   ConsumerState<ProfileTab> createState() => _ProfileTabState();
// }
//
// class _ProfileTabState extends ConsumerState<ProfileTab> {
//   final _storage = const FlutterSecureStorage();
//
//   Future<void> _logout(BuildContext context) async {
//     ref.read(accessTokenProvider.notifier).state = null;
//     await _storage.delete(key: 'refreshToken');
//
//     if (!mounted) return;
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: 220,
//         child: FilledButton(
//           onPressed: () => _logout(context),
//           child: const Text('로그아웃'),
//         ),
//       ),
//     );
//   }
// }

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const kPrimary = Color(0xFF4C46E5);
  static const kBg = Color(0xFFF6F7FB);
  static const kFieldFill = Color(0xFFF3F4F6);

  bool _isEditing = false;

  // 데모 데이터 (추후 서버/상태관리로 바꾸면 됨)
  final _idCtrl = TextEditingController(text: "");
  final _nameCtrl = TextEditingController(text: "");
  final _nickCtrl = TextEditingController(text: "");
  final _mbtiCtrl = TextEditingController(text: "INTJ");
  final _schoolCtrl = TextEditingController(text: "설정 안됨");
  final _hobbyCtrl = TextEditingController(text: "설정 안됨");
  final _classCtrl = TextEditingController(text: "");
  final _oneLineCtrl = TextEditingController(text: "");

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _nickCtrl.dispose();
    _mbtiCtrl.dispose();
    _schoolCtrl.dispose();
    _hobbyCtrl.dispose();
    _classCtrl.dispose();
    _oneLineCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: kFieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      enabled: _isEditing, // ✅ 수정 모드에서만 편집 가능
      decoration: _fieldDeco(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: Color(0xFF111827),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 헤더: 내 프로필 + 수정 버튼
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "내 프로필",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                      if (!_isEditing) {
                        // TODO: 저장 로직(서버 POST 등)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("저장(데모)")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(_isEditing ? "저장" : "수정"),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 메인 카드
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 헤더(아바타/이름/@아이디)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6ECFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 42,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "□",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "@□",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // 폼 영역
                    _label("아이디"),
                    _field(_idCtrl),

                    const SizedBox(height: 16),
                    _label("이름"),
                    _field(_nameCtrl),

                    const SizedBox(height: 16),
                    _label("별명"),
                    _field(_nickCtrl),

                    const SizedBox(height: 16),
                    _label("MBTI"),
                    // MBTI는 UI상 읽기 전용 느낌이 강해서 수정모드여도 막고 싶으면 enabled:false로 따로 처리 가능
                    TextField(
                      controller: _mbtiCtrl,
                      enabled: _isEditing, // 필요하면 false로 고정 가능
                      decoration: _fieldDeco(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _label("학교"),
                    // “설정 안됨” 같은 값은 편집모드 아니면 그대로 보여주기
                    TextField(
                      controller: _schoolCtrl,
                      enabled: _isEditing,
                      decoration: _fieldDeco(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _label("취미"),
                    TextField(
                      controller: _hobbyCtrl,
                      enabled: _isEditing,
                      decoration: _fieldDeco(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _label("분반"),
                    _field(_classCtrl),

                    const SizedBox(height: 16),
                    _label("한마디"),
                    _field(_oneLineCtrl, maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
