import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_progress_bar.dart';
import '../../design_system/widgets/q_screen.dart';
import '../../services/formation_state.dart';

/// Final step of the existing-Ltd "Open business account" flow.
/// Welcome moment with sort code + account number; flips
/// FormationState.bankAccountOpen on entry, returns to /home.
class BankingOpenScreen extends StatelessWidget {
  const BankingOpenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QProgressBar(
            step: 4,
            total: 4,
            onBack: () => context.pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to QPay.',
                  style: QPayType.heroTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sort code + account number are ready. Funded balance: £0.',
                  style: QPayType.heroSub,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _DetailsCard(
              sortCode: '04-00-04',
              accountNumber: '12345678',
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: QPayType.fieldLabel),
          const SizedBox(height: 4),
          Text(
            value,
            style: QPayType.progressNum.copyWith(
              color: QPayTokens.ink,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
