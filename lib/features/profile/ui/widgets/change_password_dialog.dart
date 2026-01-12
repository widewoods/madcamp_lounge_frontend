import 'package:flutter/material.dart';
import 'package:madcamp_lounge/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/api_client.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({
    super.key
  });

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  Future<void> _changePassword() async {
    final apiClient = ref.read(apiClientProvider);
    final res = await apiClient.patchJson(
      '/profile/edit',
      body: {
        'password': _newPasswordCtrl.text,
      },
    );

    if(!mounted) return;

    if(res.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 완료')),
      );
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 실패: ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kPrimary = Theme.of(context).primaryColor;
    final newPassword = _newPasswordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;
    final changeEnabled = newPassword == confirmPassword && _newPasswordCtrl.text.isNotEmpty;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  LockIcon(kPrimary: kPrimary),
                  const SizedBox(width: 10),
                  ChangePasswordHeader(),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "새 비밀번호",
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5,),
              TextField(
                controller: _newPasswordCtrl,
                decoration: inputDecorationWithHint("새 비밀번호 입력"),
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Text(
                "비밀번호 확인",
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5,),
              TextField(
                controller: _confirmPasswordCtrl,
                decoration: inputDecorationWithHint("비밀번호 재입력"),
                obscureText: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(width:1.6, color: Color(0xFFD5D5D5))
                      ),
                      onPressed: () {
                      Navigator.of(context).pop(context);
                        },
                      child: Text("취소"),
                    )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                      child: ElevatedButton(
                        onPressed: changeEnabled ? () {
                          _changePassword();
                          Navigator.of(context).pop(context);
                        } : null,
                        child: Text("변경하기"),
                      )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordHeader extends StatelessWidget {
  const ChangePasswordHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "비밀번호 변경",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "새로운 비밀번호를 설정하세요",
            maxLines: 1,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class LockIcon extends StatelessWidget {
  const LockIcon({
    super.key,
    required this.kPrimary,
  });

  final Color kPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECFF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: 42,
        color: kPrimary,
      ),
    );
  }
}

