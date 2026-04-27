import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/formation_state.dart';

/// A-14 · Paywall + form CTA. Top-level route.
/// Hero £100 today (Companies House pass-through, £0 QPay fee), with the
/// £15/month subscription disclosed underneath but not charged today.
/// In production the bottom CTA hands off to Apple Pay / Stripe Payment
/// Sheet — we render the Apple-Pay-style button now and connect later.
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
            _ApplePayButton(
              onPressed: () => context.push('/filing'),
            ),
            const SizedBox(height: 10),
            Text(
              'Authentic with Face ID. Charged when Companies House '
              'returns the certificate.',
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
          // ───── Hero pricing card ─────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const _HeroPricing(),
          ),
          const SizedBox(height: 16),
          // ───── Whats included ─────
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 6, 28, 0),
            child: _IncludesList(),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _HeroPricing extends StatelessWidget {
  const _HeroPricing();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: QPayTokens.ink,
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: QPayType.fieldLabel.copyWith(
              color: QPayTokens.ink4,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£100',
                style: QPayType.heroTitle.copyWith(
                  fontSize: 56,
                  height: 1,
                  color: const Color(0xFFFFFCF5),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'one-off',
                  style: QPayType.heroSub.copyWith(
                    color: QPayTokens.ink4,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'CH',
                  style: QPayType.optionTitle.copyWith(
                    fontSize: 11,
                    color: const Color(0xFFFFFCF5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Companies House filing fee',
                      style: QPayType.optionTitle.copyWith(
                        color: const Color(0xFFFFFCF5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Statutory · pass-through to GOV.UK',
                      style: QPayType.heroSub.copyWith(
                        color: QPayTokens.ink4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '£100',
                style: QPayType.optionTitle.copyWith(
                  color: const Color(0xFFFFFCF5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Q',
                  style: TextStyle(
                    color: Color(0xFFFFFCF5),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QPay formation fee',
                      style: QPayType.optionTitle.copyWith(
                        color: const Color(0xFFFFFCF5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No hidden charges. Ever.',
                      style: QPayType.heroSub.copyWith(
                        color: QPayTokens.ink4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'FREE',
                style: QPayType.optionTitle.copyWith(
                  color: QPayTokens.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(QPayTokens.rCard),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: const Color(0xFFFFFCF5).withValues(alpha: 0.85),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: QPayType.heroSub.copyWith(
                        color: const Color(0xFFFFFCF5),
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(text: 'Then '),
                        TextSpan(
                          text: '£15 / month',
                          style: QPayType.optionTitle.copyWith(
                            color: const Color(0xFFFFFCF5),
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
          Expanded(
            child: Text(text, style: QPayType.optionSub),
          ),
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
                Text(
                  'Pay  ',
                  style: QPayType.buttonLg.copyWith(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: const Icon(
                    Icons.apple,
                    size: 22,
                    color: Color(0xFFFFFCF5),
                  ),
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
