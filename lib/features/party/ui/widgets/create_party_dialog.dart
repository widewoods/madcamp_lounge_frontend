import 'package:flutter/material.dart';
import 'package:madcamp_lounge/features/party/date_formatting.dart';
import 'package:madcamp_lounge/features/party/model/party.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/pick_date_sheet.dart';
import 'package:madcamp_lounge/features/party/ui/widgets/pick_time_sheet.dart';
import 'package:madcamp_lounge/theme.dart';

class CreatePartyDialog extends StatefulWidget {
  const CreatePartyDialog({
    super.key,
    this.initialPlace,
    this.initialCategory,
  });

  final String? initialPlace;
  final String? initialCategory;

  @override
  State<CreatePartyDialog> createState() => _CreatePartyDialogState();
}

class _CreatePartyDialogState extends State<CreatePartyDialog> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  static const double _formPadding = 11;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _capacity = 4;

  @override
  void initState() {
    super.initState();
    _locationCtrl.text = widget.initialPlace ?? '';
    _categoryCtrl.text = widget.initialCategory ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _timeCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final date = _dateCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    bool disabled = title.isEmpty || category.isEmpty || date.isEmpty || time.isEmpty || location.isEmpty || content.isEmpty;

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
                          fontSize: 20,
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
                const SizedBox(height: 8),

                const Text("제목", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  decoration: inputDecorationWithHint("파티 제목"),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: _formPadding),

                const Text("날짜", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                    controller: _dateCtrl,
                    decoration: inputDecorationWithHintIcon("날짜를 선택 하세요", Icon(Icons.calendar_today_outlined)),
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

                const SizedBox(height: _formPadding),

                const Text("시간", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                    controller: _timeCtrl,
                    decoration: inputDecorationWithHintIcon("시간을 선택하세요", Icon(Icons.alarm)),
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
                const SizedBox(height: _formPadding),

                const Text("장소", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationCtrl,
                  decoration: inputDecorationWithHint("만날 장소"),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: _formPadding),

                const Text("카테고리", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryCtrl,
                  decoration: inputDecorationWithHint("예: 보드게임"),
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: _formPadding),

                const Text("설명", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentCtrl,
                  decoration: inputDecorationWithHint("설명 한두마디"),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: _formPadding),

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
                        onPressed: disabled ? null : _submit,
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
    final content = _contentCtrl.text.trim();

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
      members: [],
      content: content,
      isHost: true,
    );

    Navigator.pop(context, party);
  }
}
