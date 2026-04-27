import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../services/auth_provider.dart';
import '../../../services/formation_state.dart';

/// Home tab. Two visual states:
///   • Empty — no account opened yet. Shows the page title and two
///     large choice cards (open QPay account / connect existing bank).
///     No noise, no zeroed P&L.
///   • Active — once a QPay or external account exists, shows the
///     dashboard: balance, P&L, tax forecast, action grid.
class HomeTab extends StatelessWidget {
  final String companyName;
  const HomeTab({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final hasAccount = s.bankAccountOpen || s.externalBankLinked;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageTitle(companyName: companyName),
            const SizedBox(height: 22),
            Expanded(
              child: hasAccount
                  ? _DashboardBody(s: s)
                  : const _EmptyBody(),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Empty state: two big choice cards ─────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick how you want to bank.', style: QPayType.heroSub),
        const SizedBox(height: 18),
        _ChoiceCard(
          eyebrow: 'QPay',
          title: 'Open QPay business\naccount',
          subtitle:
              'Sort code + account number, ready in minutes. £15/mo, first month free.',
          accent: true,
          icon: Icons.account_balance_wallet_rounded,
          onTap: () => context.push('/banking-psc'),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          eyebrow: 'Open Banking',
          title: 'Connect your\nexisting bank',
          subtitle:
              'Read-only balances + transactions via TrueLayer. We never move money.',
          accent: false,
          icon: Icons.compare_arrows_rounded,
          onTap: () => context.push('/banking-connect'),
        ),
        const Spacer(),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool accent;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QPayTokens.cardBase,
      borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
            border: Border.all(
              color: accent ? QPayTokens.accent : QPayTokens.border,
              width: accent ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent ? QPayTokens.accentSoft : QPayTokens.canvas,
                  borderRadius: BorderRadius.circular(QPayTokens.rCard),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: accent ? QPayTokens.accent : QPayTokens.ink2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: QPayType.fieldLabel.copyWith(
                        color: accent
                            ? QPayTokens.accent
                            : QPayTokens.ink3,
                        letterSpacing: 1.4,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: QPayType.heroTitle.copyWith(
                        fontSize: 19,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: QPayType.heroSub),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───── Active dashboard body ─────

class _DashboardBody extends StatelessWidget {
  final FormationState s;
  const _DashboardBody({required this.s});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (s.bankAccountOpen) const _AccountCard(),
          if (s.bankAccountOpen) const SizedBox(height: 22),
          if (!s.bankAccountOpen && s.externalBankLinked) ...[
            const _ExternalLinkedCard(),
            const SizedBox(height: 22),
          ],
          const _SectionHeader(
            left: 'PROFIT & LOSS · YTD',
            right: 'Just opened',
          ),
          const SizedBox(height: 8),
          const _PnlCard(),
          const SizedBox(height: 22),
          const _SectionHeader(left: 'TAX FORECAST'),
          const SizedBox(height: 8),
          const _TaxList(),
          const SizedBox(height: 22),
          const _ActionGrid(),
          if (s.bankAccountOpen && !s.externalBankLinked) ...[
            const SizedBox(height: 22),
            _SecondaryConnectRow(),
          ],
        ],
      ),
    );
  }
}

class _SecondaryConnectRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        onTap: () => context.push('/banking-connect'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            color: QPayTokens.cardBase,
            borderRadius: BorderRadius.circular(QPayTokens.rCard),
            border: Border.all(color: QPayTokens.border, width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.compare_arrows_rounded,
                color: QPayTokens.ink2,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connect another bank · Open Banking',
                  style: QPayType.optionTitle.copyWith(fontSize: 14),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: QPayTokens.ink3, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ───── Header ─────

class _PageTitle extends StatelessWidget {
  final String companyName;
  const _PageTitle({required this.companyName});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final auth = AuthProvider.of(context);
    final name = (auth.currentName ?? s.userName).trim();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Home', style: QPayType.heroTitle.copyWith(fontSize: 26)),
              const SizedBox(height: 2),
              Text(companyName, style: QPayType.heroSub),
            ],
          ),
        ),
        Material(
          color: QPayTokens.cardBase,
          borderRadius: BorderRadius.circular(QPayTokens.rPill),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => context.push('/profile'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: QPayTokens.border, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(name),
                style: QPayType.optionTitle.copyWith(
                  fontSize: 13,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '·';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

// ───── Active dashboard tiles (unchanged from before) ─────

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: QPayTokens.ink,
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUSINESS ACCOUNT',
            style: QPayType.fieldLabel.copyWith(
              color: QPayTokens.ink4,
              fontSize: 10.5,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '£0.00',
            style: QPayType.heroTitle.copyWith(
              fontSize: 44,
              height: 1,
              color: const Color(0xFFFFFCF5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Today  ·  +£0  /  −£0',
            style: QPayType.heroSub.copyWith(
              color: QPayTokens.ink4,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalLinkedCard extends StatelessWidget {
  const _ExternalLinkedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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
              color: QPayTokens.successBg,
              borderRadius: BorderRadius.circular(QPayTokens.rMd),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 18,
              color: QPayTokens.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('External bank linked', style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text('Open Banking · TrueLayer', style: QPayType.heroSub),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String left;
  final String? right;
  const _SectionHeader({required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          left,
          style: QPayType.fieldLabel.copyWith(
            fontSize: 10.5,
            letterSpacing: 1.6,
          ),
        ),
        const Spacer(),
        if (right != null)
          Text(
            right!,
            style: QPayType.fieldLabel.copyWith(
              fontSize: 10.5,
              letterSpacing: 1.4,
              color: QPayTokens.ink4,
            ),
          ),
      ],
    );
  }
}

class _PnlCard extends StatelessWidget {
  const _PnlCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1),
      ),
      child: Column(
        children: [
          _row(label: 'Revenue', value: '£0', valueColor: QPayTokens.ink),
          const SizedBox(height: 12),
          _row(label: 'Expenses', value: '£0'),
          const SizedBox(height: 14),
          Container(height: 1, color: QPayTokens.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text('Net profit', style: QPayType.optionTitle),
              ),
              Text('£0', style: QPayType.optionTitle),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: QPayTokens.n100,
                  borderRadius: BorderRadius.circular(QPayTokens.rPill),
                ),
                child: Text(
                  '— %',
                  style: QPayType.optionSub.copyWith(
                    color: QPayTokens.ink3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: QPayType.optionSub.copyWith(
              fontSize: 14,
              color: QPayTokens.ink2,
            ),
          ),
        ),
        Text(
          value,
          style: QPayType.optionTitle.copyWith(
            color: valueColor ?? QPayTokens.ink3,
          ),
        ),
      ],
    );
  }
}

class _TaxList extends StatelessWidget {
  const _TaxList();

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
          _row(
            title: 'Corporation Tax',
            sub: 'Estimate after first year',
            value: '£0',
          ),
          _divider(),
          _row(title: 'VAT', sub: 'Not registered yet', value: '—'),
          _divider(),
          _row(title: 'PAYE', sub: 'No employees yet', value: '—'),
        ],
      ),
    );
  }

  Widget _row({
    required String title,
    required String sub,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text(sub, style: QPayType.optionSub),
              ],
            ),
          ),
          Text(
            value,
            style: QPayType.optionTitle.copyWith(color: QPayTokens.ink3),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        color: QPayTokens.border,
      );
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.north_east_rounded, 'Pay'),
      (Icons.description_outlined, 'Invoice'),
      (Icons.receipt_long_rounded, 'Receipt'),
      (Icons.diamond_outlined, 'Dividend'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _ActionTile(icon: items[i].$1, label: items[i].$2)),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: QPayTokens.canvas,
              borderRadius: BorderRadius.circular(QPayTokens.rMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: QPayTokens.ink, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: QPayType.optionSub.copyWith(
              fontWeight: FontWeight.w600,
              color: QPayTokens.ink,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
