import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Selectable option card used on S02 (intent picker) and S04 (solo / team).
/// Title + optional subtitle. A round checkbox on the top-right fills when
/// selected.
class QChoiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const QChoiceCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? QPayTokens.cardBase
        : QPayTokens.cardBase.withValues(alpha: 0.55);
    final border = selected ? QPayTokens.ink : QPayTokens.border;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(QPayTokens.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QPayTokens.rCard),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: QPayType.optionTitle),
                    if (subtitle != null) ...[
                      const SizedBox(height: QPayTokens.s3),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(subtitle!, style: QPayType.optionSub),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _Checkmark(selected: selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkmark extends StatelessWidget {
  final bool selected;
  const _Checkmark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? QPayTokens.ink : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? QPayTokens.ink : QPayTokens.n300,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFFFFFCF5))
          : const SizedBox.shrink(),
    );
  }
}
