import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_header.dart';
import '../../services/formation_state.dart';

/// B-04 · PSC verification.
/// Reads the PSC list off the public CH register. Self-PSC is marked
/// verified via /id-scan; remaining PSCs get an emailed deep-link to do
/// their own ID flow inside QPay. Account stays gated until everyone
/// clears.
class BankingPscScreen extends StatelessWidget {
  const BankingPscScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final selfName = s.userName.trim().isEmpty ? 'You' : '${s.userName.trim()} (you)';

    // Mocked list — production hits CH PSC API and renders real entries.
    final cos = const [
      _MockPsc(name: 'Sasha Petrova', share: 40),
    ];

    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackBar(),
            const QHeader(
              title: 'People with significant\ncontrol.',
              subtitle:
                  "Anyone with 25%+ shares or voting rights must verify. Co-PSCs get an email to do their own ID flow.",
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _PscRow(
                    name: selfName,
                    share: 60,
                    verified: true,
                  ),
                  for (final c in cos)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _PscRow(
                        name: c.name,
                        share: c.share,
                        verified: false,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    'If a PSC is itself a company, we walk up to the '
                    'ultimate beneficial owner.',
                    style: QPayType.heroSub,
                  ),
                ],
              ),
            ),
            QBottomBar(
              child: QButton(
                label: 'Send invites · Continue',
                onPressed: () => context.push('/banking-aml'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPsc {
  final String name;
  final int share;
  const _MockPsc({required this.name, required this.share});
}

class _PscRow extends StatelessWidget {
  final String name;
  final int share;
  final bool verified;
  const _PscRow({
    required this.name,
    required this.share,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: verified ? QPayTokens.successBg : QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(
          color: verified ? QPayTokens.success : QPayTokens.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: QPayType.optionTitle),
                const SizedBox(height: 4),
                Text('$share% shares', style: QPayType.heroSub),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: verified ? QPayTokens.success : QPayTokens.n100,
              borderRadius: BorderRadius.circular(QPayTokens.rPill),
            ),
            child: Text(
              verified ? '✓ Verified' : 'Send invite',
              style: QPayType.optionSub.copyWith(
                color: verified
                    ? const Color(0xFFFFFCF5)
                    : QPayTokens.ink2,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
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
