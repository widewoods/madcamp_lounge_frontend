import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/date_formatting.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/pick_date_sheet.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/pick_time_sheet.dart';
import 'package:madcamp_lounge/theme.dart';

class CreatePartyDialog extends StatefulWidget {
  const CreatePartyDialog({super.key});

  @override
  State<CreatePartyDialog> createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _capacity = 6;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  decoration: inputDecorationWithHint("파티 제목"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                const Text("카테고리", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryCtrl,
                  decoration: inputDecorationWithHint("예: 보드게임"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                const Text("날짜", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                    controller: _dateCtrl,
                    decoration: inputDecorationWithHint("날짜 선택"),
                    textInputAction: TextInputAction.next,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePickerSheet(context);
                      if (picked == null) return;
                      setState(() {
                        _dateCtrl.text = formatDateLabel(picked);
                      });
                      _selectedDate = picked;
                    }
                ),

                const Text("시간", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _timeCtrl,
                  decoration: inputDecorationWithHint("시간 선택"),
                  textInputAction: TextInputAction.next,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showTimeGridSheet(context);
                    if (picked == null) return;
                    setState(() {
                      _timeCtrl.text =
                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    });
                    _selectedTime = picked;
                  }
                ),
                const SizedBox(height: 12),

                const Text("장소", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationCtrl,
                  decoration: inputDecorationWithHint("만날 장소"),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 14),

                // 인원 선택
                Row(
                  children: [
                    const Text("최대 인원", style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      onPressed: _capacity > 2
                          ? () => setState(() => _capacity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text("$_capacity명", style: const TextStyle(fontWeight: FontWeight.w800)),
                    IconButton(
                      onPressed: _capacity < 20
                          ? () => setState(() => _capacity++)
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
                        child: const Text("취소"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )
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
    final date = _dateCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    if (title.isEmpty || category.isEmpty || time.isEmpty || date.isEmpty || location.isEmpty) {
      // 입력 칸 비었을 시 reject
      return;
    }

    final party = Party(
      partyId: 0,
      title: title,
      category: category,
      time: dateTimeToIsoFromPickers(selectedDate: _selectedDate!, selectedTime: _selectedTime!),
      locationText: location,
      currentCount: 1,
      targetCount: _capacity,
      imageUrl:
      "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=400&q=80",
      members: []
    );

    Navigator.pop(context, party);
  }
}
