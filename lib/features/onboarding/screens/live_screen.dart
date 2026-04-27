import 'package:flutter/material.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/formation_state.dart';
import '../../../services/postcode_service.dart';
import 'package:go_router/go_router.dart';

/// A-16 · Live. Top-level terminal route.
/// Premium "your company is real" moment — dark hero card with the
/// brand-new company number, date, and jurisdiction, framed like a
/// digital certificate. CTA pivots straight into the QPay account.
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final companyName =
        s.filedCompanyName == '—' ? 'Your Company' : s.filedCompanyName;
    final jurisdiction = s.useQPayOffice
        ? 'England and Wales'
        : (s.ownAddress?.jurisdiction.label ?? 'England and Wales');
    final today = DateTime.now();
    final incorporated = _formatDate(today);

    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: 'Open my business account',
              onPressed: () => context.go('/home'),
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
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Eyebrow celebrate row
            Row(
              children: [
                _LiveBadge(),
                const Spacer(),
                Text(
                  'Filed $incorporated',
                  style: QPayType.heroSub.copyWith(fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // ───── Certificate hero ─────
            _CertificateCard(
              companyName: companyName,
              companyNumber: '15837421',
              incorporated: incorporated,
              jurisdiction: jurisdiction,
            ),
            const SizedBox(height: 18),
            Text(
              'Your Ltd is on the public register at Companies House. '
              'The certificate is on its way to your inbox.',
              style: QPayType.heroSub,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
      decoration: BoxDecoration(
        color: QPayTokens.successBg,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: QPayTokens.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'LIVE',
            style: QPayType.fieldLabel.copyWith(
              color: QPayTokens.success,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final String companyName;
  final String companyNumber;
  final String incorporated;
  final String jurisdiction;

  const _CertificateCard({
    required this.companyName,
    required this.companyNumber,
    required this.incorporated,
    required this.jurisdiction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: QPayTokens.ink,
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
        boxShadow: [
          BoxShadow(
            color: QPayTokens.ink.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CERTIFICATE OF INCORPORATION',
                style: QPayType.fieldLabel.copyWith(
                  color: QPayTokens.accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              const _CrownEmoji(),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            companyName,
            style: QPayType.heroTitle.copyWith(
              fontSize: 30,
              height: 1.05,
              color: const Color(0xFFFFFCF5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Companies House · United Kingdom',
            style: QPayType.heroSub.copyWith(
              color: QPayTokens.ink4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  label: 'COMPANY NO.',
                  value: companyNumber,
                  mono: true,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'INCORPORATED',
                  value: incorporated,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Stat(
            label: 'JURISDICTION',
            value: jurisdiction,
          ),
        ],
      ),
    );
  }
}

class _CrownEmoji extends StatelessWidget {
  const _CrownEmoji();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text('👑', style: TextStyle(fontSize: 14)),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Stat({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: QPayType.fieldLabel.copyWith(
            color: QPayTokens.ink4,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (mono ? QPayType.progressNum : QPayType.optionTitle).copyWith(
            color: const Color(0xFFFFFCF5),
            fontSize: mono ? 16 : 16,
            letterSpacing: mono ? 1.1 : -0.2,
          ),
        ),
      ],
    );
  }
}
