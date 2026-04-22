import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

enum QButtonKind { primary, secondary, ghost, accent }

enum QButtonSize { lg, md, sm }

/// Pill CTA. Defaults to a 56-pt black primary used at the bottom of every
/// onboarding screen; secondary / ghost variants keep the same pill shape.
class QButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final QButtonKind kind;
  final QButtonSize size;
  final bool full;

  const QButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = QButtonKind.primary,
    this.size = QButtonSize.lg,
    this.full = true,
  });

  @override
  State<QButton> createState() => _QButtonState();
}

class _QButtonState extends State<QButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final height = switch (widget.size) {
      QButtonSize.lg => 56.0,
      QButtonSize.md => 48.0,
      QButtonSize.sm => 38.0,
    };
    final paddingH = switch (widget.size) {
      QButtonSize.lg => 24.0,
      QButtonSize.md => 18.0,
      QButtonSize.sm => 14.0,
    };
    final label = switch (widget.size) {
      QButtonSize.lg => QPayType.buttonLg,
      QButtonSize.md => QPayType.buttonSecondary.copyWith(fontSize: 14),
      QButtonSize.sm => QPayType.buttonSecondary.copyWith(fontSize: 12),
    };

    final (bg, fg, borderColor) = switch (widget.kind) {
      QButtonKind.primary => (QPayTokens.ink, QPayTokens.primaryInk, Colors.transparent),
      QButtonKind.accent => (QPayTokens.accent, QPayTokens.primaryInk, Colors.transparent),
      QButtonKind.secondary => (
          QPayTokens.cardBase.withValues(alpha: 0.85),
          QPayTokens.ink,
          QPayTokens.border,
        ),
      QButtonKind.ghost => (Colors.transparent, QPayTokens.ink, Colors.transparent),
    };

    final effectiveBg = disabled ? QPayTokens.n100 : bg;
    final effectiveFg = disabled ? QPayTokens.ink4 : fg;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: SizedBox(
        width: widget.full ? double.infinity : null,
        height: height,
        child: Material(
          color: effectiveBg,
          shape: StadiumBorder(
            side: borderColor == Colors.transparent
                ? BorderSide.none
                : BorderSide(color: borderColor, width: 1.5),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              child: Center(
                child: Text(
                  widget.label,
                  style: label.copyWith(color: effectiveFg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
