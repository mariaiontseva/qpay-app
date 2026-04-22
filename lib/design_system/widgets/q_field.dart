import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';
import '../typography.dart';

/// Text input — warm fill, 12-px corners, accent focus ring, optional prefix
/// widget (used on the +44 phone field in S01).
class QField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? placeholder;
  final TextEditingController? controller;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? autofillHint;
  final bool autofocus;

  const QField({
    super.key,
    this.label,
    this.hint,
    this.placeholder,
    this.controller,
    this.prefix,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.autofillHint,
    this.autofocus = false,
  });

  @override
  State<QField> createState() => _QFieldState();
}

class _QFieldState extends State<QField> {
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _node.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: QPayType.fieldLabel),
          const SizedBox(height: QPayTokens.s2 + 2),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: QPayTokens.cardBase.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(QPayTokens.rMd),
            border: Border.all(
              color: focused ? QPayTokens.accent : QPayTokens.border,
              width: 1.5,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: QPayTokens.accent.withValues(alpha: 0.14),
                      blurRadius: 0,
                      spreadRadius: 4,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _node,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  autofillHints: widget.autofillHint != null
                      ? [widget.autofillHint!]
                      : null,
                  style: QPayType.fieldInput,
                  cursorColor: QPayTokens.ink,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: widget.placeholder,
                    hintStyle: QPayType.fieldInput.copyWith(
                      color: QPayTokens.ink4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: QPayTokens.s2 + 2),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(widget.hint!, style: QPayType.fieldHint),
          ),
        ],
      ],
    );
  }
}
