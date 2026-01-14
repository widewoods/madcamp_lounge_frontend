import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:madcamp_lounge/api_client.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/change_password_dialog.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/editable_field.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/expandable_bio.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/fixed_field.dart';
import 'package:madcamp_lounge/features/profile/ui/widgets/profile_appbar.dart';
import 'package:madcamp_lounge/gradient_button.dart';
import 'package:madcamp_lounge/pages/login.dart';
import 'package:madcamp_lounge/state/auth_state.dart';
import 'package:madcamp_lounge/theme.dart';

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

  Future<void> _logout() async {
    final storage = const FlutterSecureStorage();
    final refreshToken = await storage.read(key: 'refreshToken');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.postJson(
        '/auth/logout',
        body: {'refresh_token': refreshToken},
        useAuth: false,
      );
    }

    await storage.delete(key: 'refreshToken');
    ref.read(accessTokenProvider.notifier).state = null;

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: Color(0xFF5A5A5A),
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
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsetsDirectional.only(bottom: 0.0),
                          child: Align(
                            alignment: AlignmentGeometry.center,
                            child: Text(
                              _nameCtrl.text.isEmpty ? '' : _nameCtrl.text[0],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 43,
                                fontWeight: FontWeight.bold
                              ),
                            ),
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
                              SizedBox(height: 2),
                              Text(
                                "@${_idCtrl.text}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: 4),
                              ExpandableBio(bio: _introductionCtrl.text),
                              // Text(
                              //   _introductionCtrl.text,
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.w700,
                              //     color: Color(0xFF575757),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

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
                    _label("취미"),
                    EditableField(ctrl: _hobbyCtrl, isEditing: _isEditing,),

                    const SizedBox(height: 5),
                    _label("학교"),
                    FixedField(ctrl: _schoolCtrl),

                    const SizedBox(height: 5),
                    _label("분반"),
                    FixedField(ctrl: _classCtrl),

                    const SizedBox(height: 5),
                    if(_isEditing)
                      _label("한마디"),
                    if(_isEditing)
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
                          child: GradientButton(
                            onPressed: () async {
                              setState(() => _isEditing = !_isEditing);
                              if (!_isEditing) {
                                await _saveProfile();
                              }
                            },
                            icon: const Icon(Icons.edit, size: 18, color: Colors.white,),
                            text: _isEditing ? "저장" : "수정",
                            colors: gradientColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
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
