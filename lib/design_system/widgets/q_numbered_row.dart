import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Numbered checklist row used on S03 (pre-flight).
/// Small black circle with a mono number, title + sub.
class QNumberedRow extends StatelessWidget {
  final int number;
  final String title;
  final String sub;
  final bool isFirst;

  const QNumberedRow({
    super.key,
    required this.number,
    required this.title,
    required this.sub,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isFirst
              ? const BorderSide(color: QPayTokens.border)
              : BorderSide.none,
          bottom: const BorderSide(color: QPayTokens.border),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: QPayTokens.ink,
              shape: BoxShape.circle,
            ),
            child: Text('$number', style: QPayType.checklistNumber),
          ),
          const SizedBox(width: QPayTokens.s4 + 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: QPayType.checklistTitle),
                  const SizedBox(height: 3),
                  Text(sub, style: QPayType.checklistSub),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
