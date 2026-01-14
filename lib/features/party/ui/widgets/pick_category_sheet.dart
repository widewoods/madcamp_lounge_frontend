import 'package:flutter/material.dart';
import 'package:madcamp_lounge/theme.dart';

import '../../../recommend/model/recommend_category.dart';

Future<String?> showPickCategorySheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
    builder: (sheetCtx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom, // ✅ 키보드 높이
        ),
        child: const _PickCategorySheetBody(),
      );
    },
  );
}

class _PickCategorySheetBody extends StatefulWidget {
  const _PickCategorySheetBody({super.key});

  @override
  State<_PickCategorySheetBody> createState() => _PickCategorySheetBodyState();
}

class _PickCategorySheetBodyState extends State<_PickCategorySheetBody> {
  final _etcController = TextEditingController();
  final _etcFocus = FocusNode();
  bool _showEtcInput = false;

  @override
  void dispose() {
    _etcController.dispose();
    _etcFocus.dispose();
    super.dispose();
  }

  void _select(String value) => Navigator.pop(context, value);

  void _openEtc() {
    setState(() => _showEtcInput = true);
    Future.microtask(() => _etcFocus.requestFocus());
  }

  void _submitEtc() {
    final text = _etcController.text.trim();
    if (text.isEmpty) return;
    _select(text);
  }

  @override
  Widget build(BuildContext context) {
    final categories = recommendCategories;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("카테고리",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...categories.map((c) => _CategoryChip(
                      label: c.title,
                      onTap: () => _select(c.id),
                    )),
                    _CategoryChip(
                      label: '기타',
                      onTap: _openEtc,
                      emphasized: true,
                    ),
                  ],
                ),

                if (_showEtcInput) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _etcController,
                          focusNode: _etcFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitEtc(),
                          decoration: const InputDecoration(
                            hintText: '카테고리를 입력하세요',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: _submitEtc,
                        child: const Text('완료'),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showEtcInput = false;
                            _etcController.clear();
                          });
                        },
                        child: const Text('취소', style: TextStyle(color: kPrimary),),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: emphasized ? Theme.of(context).primaryColor : const Color(0xFFDADDE5),
            width: 1.4,
          ),
          color: emphasized ? Theme.of(context).primaryColor.withOpacity(0.06) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: emphasized ? Theme.of(context).primaryColor : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
