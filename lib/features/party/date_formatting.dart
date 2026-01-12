
import 'package:flutter/material.dart';

DateTime parseIso(String iso) {
  return DateTime.parse(iso);
}

String _two(int n) => n.toString().padLeft(2, '0');

String _weekdayKor(int weekday) {
  const wd = ['월', '화', '수', '목', '금', '토', '일'];
  return wd[weekday - 1];
}

String _ampmKor(int hour) => hour < 12 ? '오전' : '오후';

int _to12Hour(int hour) {
  if (hour == 0) return 12;
  if (hour > 12) return hour - 12;
  return hour;
}

String formatIsoKorean(DateTime dt) {
  final wd = _weekdayKor(dt.weekday);
  final ampm = _ampmKor(dt.hour);
  final h12 = _to12Hour(dt.hour);
  final mm = _two(dt.minute);
  return "${dt.month}월 ${dt.day}일 ($wd) $ampm $h12:$mm";
}

DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String toIsoNoMillis(DateTime dt) {
  return "${dt.year}-${_two(dt.month)}-${_two(dt.day)}"
      "T${_two(dt.hour)}:${_two(dt.minute)}:00";
}

String dateTimeToIsoFromPickers({
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
}) {
  final dt = combineDateAndTime(selectedDate, selectedTime);
  return toIsoNoMillis(dt);
}