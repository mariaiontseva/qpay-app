import 'package:flutter/material.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-16 · Live. Top-level terminal route.
/// Company is now incorporated. Real CH would return company number,
/// incorporation date, and a certificate URL — mocked here.
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: 'Open my business account',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                'Download certificate (PDF)',
                style: QPayType.statusLineStrong,
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 60, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: QPayTokens.successBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  color: QPayTokens.success,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Orca Design Ltd\nis live.',
              textAlign: TextAlign.center,
              style: QPayType.heroTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Your company exists at Companies House.',
              textAlign: TextAlign.center,
              style: QPayType.heroSub,
            ),
            const SizedBox(height: 24),
            const _Row(label: 'Company number', value: '15837421', mono: true),
            const _Row(label: 'Incorporated', value: '27 Apr 2026'),
            const _Row(label: 'Jurisdiction', value: 'England and Wales'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Row({required this.label, required this.value, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        decoration: BoxDecoration(
          color: QPayTokens.cardBase.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(QPayTokens.rCard),
          border: Border.all(color: QPayTokens.border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: QPayType.fieldLabel)),
            Text(
              value,
              style: mono
                  ? QPayType.fieldHint.copyWith(
                      fontFamily: 'JetBrainsMono',
                      color: QPayTokens.ink,
                      fontSize: 14,
                    )
                  : QPayType.optionTitle,
            ),
          ],
        ),
      ),
    );
  }
}
