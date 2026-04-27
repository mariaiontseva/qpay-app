import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_screen.dart';
import '../../services/formation_state.dart';

/// Final step of the existing-Ltd "Open business account" flow.
/// Lights up sort code + account number, marks the banking flow complete
/// in FormationState, returns to /home.
class BankingOpenScreen extends StatelessWidget {
  const BankingOpenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    // Mark banking complete the first time we land here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!s.bankAccountOpen) s.setBankAccountOpen(true);
    });
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Open my dashboard',
          onPressed: () => context.go('/home'),
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
              'Your business\naccount is open.',
              textAlign: TextAlign.center,
              style: QPayType.heroTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Sort code + account number are ready. Funded balance: £0.',
              textAlign: TextAlign.center,
              style: QPayType.heroSub,
            ),
            const SizedBox(height: 24),
            const _DetailsCard(
              sortCode: '04-00-04',
              accountNumber: '12345678',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String sortCode;
  final String accountNumber;

  const _DetailsCard({required this.sortCode, required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1),
      ),
      child: Column(
        children: [
          _row('SORT CODE', sortCode),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: QPayTokens.border,
          ),
          _row('ACCOUNT NUMBER', accountNumber),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: QPayType.fieldLabel),
          ),
          Text(
            value,
            style: QPayType.progressNum.copyWith(
              color: QPayTokens.ink,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
