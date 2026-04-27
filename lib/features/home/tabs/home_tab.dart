import 'package:flutter/material.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';

/// Home tab content — fresh business account, all numbers at zero.
class HomeTab extends StatelessWidget {
  final String companyName;
  const HomeTab({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageTitle(companyName: companyName),
            const SizedBox(height: 18),
            const _AccountCard(),
            const SizedBox(height: 22),
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
          ],
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String companyName;
  const _PageTitle({required this.companyName});

  @override
  Widget build(BuildContext context) {
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
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: QPayTokens.cardBase,
            borderRadius: BorderRadius.circular(QPayTokens.rMd),
            border: Border.all(color: QPayTokens.border, width: 1),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.notifications_none_rounded,
            color: QPayTokens.ink2,
            size: 18,
          ),
        ),
      ],
    );
  }
}

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
                child: Text(
                  'Net profit',
                  style: QPayType.optionTitle,
                ),
              ),
              Text('£0', style: QPayType.optionTitle),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
