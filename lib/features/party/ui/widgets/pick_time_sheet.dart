import 'package:flutter/material.dart';

Future<TimeOfDay?> showTimeGridSheet(BuildContext context) {
  final times = <TimeOfDay>[];
  for (int h = 9; h <= 21; h++) {
    times.add(TimeOfDay(hour: h, minute: 0));
    times.add(TimeOfDay(hour: h, minute: 30));
  }
  times.add(TimeOfDay(hour: 22, minute: 0));

  String fmt(TimeOfDay t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.55, // 화면의 55%
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            // 그리드
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: times.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (_, i) {
                  final t = times[i];
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context, t),
                    child: Text(fmt(t)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
