import 'package:flutter/material.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';

/// Placeholder tab for the not-yet-shipped sections (Money / Books /
/// Taxes / Company). On-brand empty state with the tab title and a
/// short subtitle.
class EmptyTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyTab({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: QPayType.heroTitle.copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text(subtitle, style: QPayType.heroSub),
            const Spacer(),
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: QPayTokens.cardBase,
                  borderRadius: BorderRadius.circular(QPayTokens.rCard),
                  border: Border.all(color: QPayTokens.border, width: 1),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: QPayTokens.ink3,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Nothing to show yet.',
                style: QPayType.heroSub,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
