import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_screen.dart';
import '../../services/formation_state.dart';

/// Connect-an-existing-bank flow via Open Banking. Production talks to a
/// FCA-regulated AISP (TrueLayer / Plaid / Tink); the prototype mocks the
/// connection so the dashboard reflects "external bank linked".
class OpenBankingScreen extends StatelessWidget {
  const OpenBankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: 'Continue with TrueLayer',
              onPressed: () {
                s.setExternalBankLinked(true);
                context.go('/home');
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Read-only access to balances + transactions. We never move money.',
              textAlign: TextAlign.center,
              style: QPayType.termsFooter,
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.translucent,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: QPayTokens.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('Connect your bank.',
                style: QPayType.heroTitle.copyWith(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              "Link an existing UK bank with Open Banking. We pull balances "
              "and transactions read-only — your bank is in charge of the "
              "auth.",
              style: QPayType.heroSub,
            ),
            const SizedBox(height: 20),
            const _Bullet(text: 'FCA-regulated, PSD2-compliant'),
            const _Bullet(text: 'Read-only — we cannot move money'),
            const _Bullet(text: 'Revoke access from your bank app any time'),
            const SizedBox(height: 24),
            const _ProviderRow(),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded,
              color: QPayTokens.success, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: QPayType.optionSub)),
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: QPayTokens.canvas,
              borderRadius: BorderRadius.circular(QPayTokens.rMd),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.account_balance_rounded,
                size: 18, color: QPayTokens.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open Banking via TrueLayer', style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text('Pick from 30+ UK banks', style: QPayType.heroSub),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: QPayTokens.ink3, size: 22),
        ],
      ),
    );
  }
}
