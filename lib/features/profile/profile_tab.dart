import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/change_password_dialog.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/editable_field.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/fixed_field.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/profile_appbar.dart';
import 'package:madcamp_lounge/pages/login.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {

  static const kPrimary = Color(0xFF4C46E5);

  bool _isEditing = false;

  // 수정 모드에서
  final _idCtrl = TextEditingController(text: "");
  final _nameCtrl = TextEditingController(text: "");
  final _nickCtrl = TextEditingController(text: "");
  final _mbtiCtrl = TextEditingController(text: "");
  final _schoolCtrl = TextEditingController(text: "");
  final _hobbyCtrl = TextEditingController(text: "");
  final _classCtrl = TextEditingController(text: "");
  final _introductionCtrl = TextEditingController(text: "");

  Future<void> _loadProfile() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.get('/profile/me');

    if(!mounted) return;

    if(res.statusCode == 200){
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      _idCtrl.text = (data['loginId'] ?? '').toString();
      _nameCtrl.text = (data['name'] ?? '').toString();
      _nickCtrl.text = (data['nickname'] ?? '').toString();
      _mbtiCtrl.text = (data['mbti'] ?? '').toString();
      _schoolCtrl.text = (data['university'] ?? '').toString();
      _hobbyCtrl.text = (data['hobby'] ?? '').toString();
      _classCtrl.text = (data['classSection'] ?? '').toString();
      _introductionCtrl.text = (data['introduction'] ?? '').toString();

      setState(() {});
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res.statusCode}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final apiClient = ref.read(apiClientProvider);
    final body = <String, dynamic>{};
    final nickname = _nickCtrl.text.trim();
    if(nickname.isNotEmpty) body['nickname'] = nickname;

    final hobby = _hobbyCtrl.text.trim();
    if(hobby.isNotEmpty) body['hobby'] = hobby;

    final introduction = _introductionCtrl.text.trim();
    if(introduction.isNotEmpty) body['introduction'] = introduction;


    final res = await apiClient.patchJson(
      '/profile/edit',
      body: body,
    );

    if(!mounted) return;

    if(res.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 완료'), duration: Duration(seconds: 1),),
      );
      setState(() {});
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${res.statusCode}')),
      );
    }
  }

  Future<void> _openChangePasswordDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _nickCtrl.dispose();
    _mbtiCtrl.dispose();
    _schoolCtrl.dispose();
    _hobbyCtrl.dispose();
    _classCtrl.dispose();
    _introductionCtrl.dispose();
    super.dispose();
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: Color(0xFF4C46E5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize:
      const Size.fromHeight(kToolbarHeight),
        child: ProfileAppbar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                            children: [
                              Text(
                                _nameCtrl.text,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "@${_idCtrl.text}",
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

                    const SizedBox(height: 10),

                    // 폼 영역
                    _label("아이디"),
                    FixedField(ctrl: _idCtrl,),

                    const SizedBox(height: 5),
                    _label("이름"),
                    FixedField(ctrl: _nameCtrl,),

                    const SizedBox(height: 5),
                    _label("별명"),
                    EditableField(ctrl: _nickCtrl, isEditing: _isEditing,),

                    const SizedBox(height: 5),
                    _label("MBTI"),
                    FixedField(ctrl: _mbtiCtrl,),

                    const SizedBox(height: 5),
                    _label("학교"),
                    FixedField(ctrl: _schoolCtrl),

                    const SizedBox(height: 5),
                    _label("취미"),
                    EditableField(ctrl: _hobbyCtrl, isEditing: _isEditing,),

                    const SizedBox(height: 5),
                    _label("분반"),
                    FixedField(ctrl: _classCtrl),

                    const SizedBox(height: 5),
                    _label("한마디"),
                    EditableField(ctrl: _introductionCtrl, isEditing: _isEditing,),
                    const SizedBox(height: 20,),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _openChangePasswordDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline),
                                const SizedBox(width: 3),
                                Text("비밀번호 변경"),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() => _isEditing = !_isEditing);
                              if (!_isEditing) {
                                await _saveProfile();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_outlined),
                    const SizedBox(width: 4),

                    Text("로그아웃"),
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
