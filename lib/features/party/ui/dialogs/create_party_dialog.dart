import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';

class CreatePartyDialog extends StatefulWidget {
  const CreatePartyDialog({super.key});

  @override
  State<CreatePartyDialog> createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> {
  static const kPrimary = Color(0xFF4C46E5);

  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  int _maxPeople = 6;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "파티 만들기",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                const Text("제목", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  decoration: _dec("예: 보드게임 같이 하실 분!"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                const Text("카테고리", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryCtrl,
                  decoration: _dec("예: 보드게임"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                const Text("시간", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _timeCtrl,
                  decoration: _dec("예: 오늘 오후 7시"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                const Text("장소", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationCtrl,
                  decoration: _dec("예: 강남 보드게임카페"),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 14),

                // 인원 선택
                Row(
                  children: [
                    const Text("최대 인원", style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      onPressed: _maxPeople > 2
                          ? () => setState(() => _maxPeople--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text("$_maxPeople명", style: const TextStyle(fontWeight: FontWeight.w800)),
                    IconButton(
                      onPressed: _maxPeople < 20
                          ? () => setState(() => _maxPeople++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("취소"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        child: const Text("만들기"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (title.isEmpty || category.isEmpty || time.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 항목을 입력해주세요")),
      );
      return;
    }

    final party = Party(
      title: title,
      category: category,
      timeText: time,
      locationText: location,
      current: 1,
      max: _maxPeople,
      imageUrl:
      "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
    );

    Navigator.pop(context, party);
  }
}
