import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/formation_state.dart';

/// A-14 · Paywall + form CTA. Top-level route.
/// Light, paper-feel design — no dark content blocks. Hero £100 is the
/// only one-off charge; £15/month for QPay Business is disclosed but not
/// charged today (first month free). The bottom Apple-Pay-style CTA is
/// dark by design — Apple HIG requires the dark variant.
class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final companyName =
        s.filedCompanyName == '—' ? 'your company' : s.filedCompanyName;

    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ApplePayButton(onPressed: () => context.push('/filing')),
            const SizedBox(height: 10),
            Text(
              'Charged when Companies House returns the certificate.',
              textAlign: TextAlign.center,
              style: QPayType.termsFooter,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last step.',
                  style: QPayType.fieldLabel.copyWith(
                    color: QPayTokens.accent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'File $companyName with\nCompanies House.',
                  style: QPayType.heroTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'One tap. Companies House usually returns the '
                  'incorporation certificate in under 30 seconds.',
                  style: QPayType.heroSub,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _PricingCard(),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: _IncludesList(),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
        border: Border.all(color: QPayTokens.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: QPayType.fieldLabel.copyWith(
              color: QPayTokens.ink3,
              fontSize: 10.5,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£100',
                style: QPayType.heroTitle.copyWith(
                  fontSize: 34,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'one-off',
                  style: QPayType.heroSub.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: QPayTokens.border),
          const SizedBox(height: 14),
          const _LineItem(
            initials: 'CH',
            title: 'Companies House filing fee',
            sub: 'Statutory · pass-through to GOV.UK',
            valueText: '£100',
          ),
          const SizedBox(height: 14),
          const _LineItem(
            initials: 'Q',
            title: 'QPay formation fee',
            sub: 'No hidden charges. Ever.',
            valueText: 'FREE',
            valueAccent: true,
          ),
          const SizedBox(height: 18),
          const _MonthlyPanel(),
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String initials;
  final String title;
  final String sub;
  final String valueText;
  final bool valueAccent;

  const _LineItem({
    required this.initials,
    required this.title,
    required this.sub,
    required this.valueText,
    this.valueAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: QPayTokens.canvas,
            shape: BoxShape.circle,
            border: Border.all(color: QPayTokens.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: QPayType.optionTitle.copyWith(
              fontSize: 11,
              color: QPayTokens.ink2,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: QPayType.optionTitle),
              const SizedBox(height: 2),
              Text(sub, style: QPayType.heroSub),
            ],
          ),
        ),
        Text(
          valueText,
          style: QPayType.optionTitle.copyWith(
            color: valueAccent ? QPayTokens.accent : QPayTokens.ink,
          ),
        ),
      ],
    );
  }
}

class _MonthlyPanel extends StatelessWidget {
  const _MonthlyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: QPayTokens.successBg,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: QPayTokens.success,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: QPayType.heroSub.copyWith(
                  color: QPayTokens.success,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: 'Then '),
                  TextSpan(
                    text: '£15 / month',
                    style: QPayType.optionTitle.copyWith(
                      color: QPayTokens.success,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' from next month for QPay Business — first month on us. Cancel anytime.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncludesList extends StatelessWidget {
  const _IncludesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _IncludeRow(text: 'Business account ready the moment CH confirms'),
        _IncludeRow(text: 'All formation filings forever — no per-doc charges'),
        _IncludeRow(text: 'Cap table, PSC register, CT reminders'),
        _IncludeRow(text: 'Confirmation Statement filing absorbed each year'),
      ],
    );
  }
}

class _IncludeRow extends StatelessWidget {
  final String text;
  const _IncludeRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_rounded,
            color: QPayTokens.success,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: QPayType.optionSub)),
        ],
      ),
    );
  }
}

class _ApplePayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _ApplePayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: QPayTokens.ink,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Pay  ',
                    style: QPayType.buttonLg.copyWith(fontSize: 17)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.apple,
                      size: 22, color: Color(0xFFFFFCF5)),
                ),
                Text(
                  ' Pay  ·  £100',
                  style: QPayType.buttonLg.copyWith(fontSize: 17),
                ),
              ],
            ),
          ),
        ),
      ),
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
