import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-14 · Pricing + form CTA. Top-level route.
/// Pricing is held until the very last screen. £100 is a pure Companies
/// House pass-through; QPay formation fee is £0. Subscription is disclosed
/// here but not charged today.
class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Form my company · £100',
          onPressed: () => context.push('/filing'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          const QHeader(
            title: 'Form your\ncompany.',
            subtitle:
                'One tap to file. Companies House usually returns under 30 seconds.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _LineItem(label: 'Companies House fee', value: '£100'),
                _LineItem(
                  label: 'QPay formation fee',
                  value: '£0',
                  valueColor: QPayTokens.success,
                ),
                SizedBox(height: 6),
                _TodayCard(),
                SizedBox(height: 14),
                _MonthlyNote(),
                SizedBox(height: 14),
                _LineItem(label: 'Card', value: '•••• 4242', mono: true),
              ],
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool mono;
  const _LineItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final valStyle = (mono ? QPayType.fieldHint : QPayType.optionTitle)
        .copyWith(color: valueColor ?? QPayTokens.ink);
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
            Text(value, style: valStyle),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: QPayTokens.successBg,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.success, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Today',
              style: QPayType.fieldLabel.copyWith(
                color: QPayTokens.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '£100',
            style: QPayType.heroTitle.copyWith(
              fontSize: 22,
              color: QPayTokens.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyNote extends StatelessWidget {
  const _MonthlyNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'After incorporation: QPay Business £15/month, first month free. Cancel anytime.',
      style: QPayType.heroSub.copyWith(fontSize: 12.5),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(QPayTokens.s5, 10, QPayTokens.s6, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
