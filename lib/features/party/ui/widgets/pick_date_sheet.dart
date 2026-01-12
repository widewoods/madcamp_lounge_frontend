import 'package:flutter/material.dart';

String formatDateLabel(DateTime d) {
  final now = DateTime.now();

  const wd = ["월", "화", "수", "목", "금", "토", "일"];
  final weekday = wd[d.weekday - 1];
  return "${d.month}월 ${d.day}일 ($weekday)";
}

Future<DateTime?> showDatePickerSheet(BuildContext context) {
  final now = DateTime.now();
  final dates = List.generate(14, (i) => DateTime(now.year, now.month, now.day + i));

  String labelFor(DateTime d) {
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return "오늘 (${d.month}월 ${d.day}일)";
    if (diff == 1) return "내일 (${d.month}월 ${d.day}일)";
    const wd = ["월", "화", "수", "목", "금", "토", "일"];
    return "${d.month}월 ${d.day}일 (${wd[d.weekday - 1]})";
  }

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.55, // 화면의 55%
    ),
    builder: (_) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final d = dates[i];
          return ListTile(
            title: Text(
              labelFor(d),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            onTap: () => Navigator.pop(context, d),
          );
        },
      ),
    ),
  );
}
