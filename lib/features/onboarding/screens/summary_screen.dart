import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';

/// A-09 · Company summary. Lives inside [OnboardingShell].
/// Folds name + SIC + office + articles + auto-config (solo · 100 shares ·
/// 100% PSC) onto a single review screen. Each row is tappable to edit.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Looks right',
          onPressed: () => context.push('/director-details'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Looks right?',
            subtitle: "Quick review of what you've told us. Tap any line to change it.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _Row(
                  label: 'Company name',
                  value: 'Orca Design Ltd',
                  route: '/name',
                ),
                _Row(
                  label: 'SIC code',
                  value: '62012 · Software dev',
                  route: '/sic',
                ),
                _Row(
                  label: 'Registered office',
                  value: 'QPay London · 411 Oxford St',
                  route: '/registered-office',
                ),
                _Row(
                  label: 'Articles',
                  value: 'Model · standard',
                  route: '/articles',
                ),
                _Row(
                  label: 'Director · shares · PSC',
                  value: 'You · 100 shares · 100% PSC',
                ),
              ],
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final String? route;

  const _Row({required this.label, required this.value, this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QPayTokens.s3),
      child: Material(
        color: QPayTokens.cardBase.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: InkWell(
          onTap: route != null ? () => context.go(route!) : null,
          borderRadius: BorderRadius.circular(QPayTokens.rCard),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QPayTokens.rCard),
              border: Border.all(color: QPayTokens.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: QPayType.fieldLabel),
                      const SizedBox(height: 4),
                      Text(value, style: QPayType.optionTitle),
                    ],
                  ),
                ),
                if (route != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: QPayTokens.ink3,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
