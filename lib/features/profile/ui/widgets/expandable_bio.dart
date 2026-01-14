import 'package:flutter/material.dart';

class ExpandableBio extends StatefulWidget {
  const ExpandableBio({
    super.key,
    required this.bio,
    this.collapsedMaxLines = 2,
    this.textStyle = const TextStyle(
      fontSize: 13.5,
      height: 1.25,
      color: Color(0xFF4B5563), // gray-600
      fontWeight: FontWeight.w600,
    ),
    this.actionStyle = const TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
      color: Color(0xFF10B981), // theme green
    ),
    this.actionPadding = const EdgeInsets.only(top: 4),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 180),
  });

  final String bio;
  final int collapsedMaxLines;
  final TextStyle textStyle;
  final TextStyle actionStyle;
  final EdgeInsets actionPadding;
  final bool animate;
  final Duration animationDuration;

  @override
  State<ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<ExpandableBio> {
  bool _expanded = false;
  bool _overflow = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalcOverflow();
  }

  @override
  void didUpdateWidget(covariant ExpandableBio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bio != widget.bio ||
        oldWidget.collapsedMaxLines != widget.collapsedMaxLines ||
        oldWidget.textStyle != widget.textStyle) {
      _expanded = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _recalcOverflow());
    }
  }

  void _recalcOverflow() {
    final t = widget.bio.trim();
    if (t.isEmpty) {
      if (mounted) setState(() => _overflow = false);
      return;
    }

    final maxWidth = MediaQuery.of(context).size.width;
    final availableWidth = maxWidth * 0.70;

    final painter = TextPainter(
      text: TextSpan(text: t, style: widget.textStyle),
      maxLines: widget.collapsedMaxLines,
      textDirection: TextDirection.ltr,
      ellipsis: '…',
    )..layout(maxWidth: availableWidth);

    final didOverflow = painter.didExceedMaxLines;
    if (mounted) setState(() => _overflow = didOverflow);
  }

  @override
  Widget build(BuildContext context) {
    final bio = widget.bio.trim();
    if (bio.isEmpty) return const SizedBox.shrink();

    final text = Text(
      bio,
      style: widget.textStyle,
      maxLines: _expanded ? null : widget.collapsedMaxLines,
      overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.animate
            ? AnimatedSize(
          duration: widget.animationDuration,
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: text,
        )
            : text,
        if (_overflow) Padding(padding: widget.actionPadding, child: _action()),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _overflow ? _toggle : null,
      child: content,
    );
  }

  Widget _action() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(_expanded ? '접기' : '더보기', style: widget.actionStyle),
      ),
    );
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }
}
