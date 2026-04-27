import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';

/// A-08 · Articles of association. Lives inside [OnboardingShell].
/// Single-option screen: Model Articles is the Companies Act 2006 default,
/// always pre-selected. Bespoke articles are an after-incorporation upsell
/// for Q Accountants.
class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: () => context.push('/summary'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          QHeader(
            title: 'Articles of\nassociation.',
            subtitle: 'The rulebook for your company. We file the standard one.',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: _ModelArticlesCard(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _BespokeNote(),
          ),
          SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _BespokeNote extends StatelessWidget {
  const _BespokeNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Need bespoke articles? Tell us after incorporation and Q Accountants will draft them.',
      style: QPayType.optionSub.copyWith(color: QPayTokens.ink3),
    );
  }
}

class _ModelArticlesCard extends StatelessWidget {
  const _ModelArticlesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'Model Articles · standard',
                    style: QPayType.optionTitle,
                  ),
                ),
              ),
              const _CheckBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Companies Act 2006 default. No amendments. 95% of UK Ltds use this.',
            style: QPayType.optionSub,
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: QPayTokens.border),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StatCell(value: '£0', label: 'COST')),
              Expanded(child: _StatCell(value: '0 min', label: 'TO REVIEW')),
              Expanded(child: _StatCell(value: '95%', label: 'OF UK LTDS')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: QPayTokens.ink,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFFFFFCF5)),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: QPayType.optionTitle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: QPayType.progressNum.copyWith(color: QPayTokens.ink3),
        ),
      ],
    );
  }
}
