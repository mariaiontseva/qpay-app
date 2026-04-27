import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_header.dart';
import '../../design_system/widgets/q_pick_page.dart';
import '../../services/formation_state.dart';

/// B-05 · Source of funds + expected monthly volume.
/// Mandatory under MLR 2017 § 28. Two pickers, both required to proceed.
class BankingAmlScreen extends StatelessWidget {
  const BankingAmlScreen({super.key});

  static const _sourceOptions = [
    'Trading revenue',
    'Capital injection',
    'Loan',
    'Investment',
    'Other',
  ];

  static const _volumeOptions = [
    '£0 – £10k',
    '£10k – £50k',
    '£50k – £200k',
    '£200k+',
  ];

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final ok = s.sourceOfFunds.isNotEmpty && s.expectedVolume.isNotEmpty;
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackBar(),
            const QHeader(
              title: 'How will the\naccount be used?',
              subtitle:
                  'Two AML questions, satisfies MLR § 28. We don\'t share these — they sit in your business profile.',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                children: [
                  _PickField(
                    label: 'Source of funds',
                    value: s.sourceOfFunds,
                    placeholder: 'Tap to choose',
                    onTap: () async {
                      final v = await pushQPickPage<String>(
                        context,
                        title: 'Source of funds',
                        options: _sourceOptions,
                        labelFor: (s) => s,
                        searchKeyFor: (s) => s,
                        selected: s.sourceOfFunds.isEmpty
                            ? null
                            : s.sourceOfFunds,
                      );
                      if (v != null) s.setSourceOfFunds(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _PickField(
                    label: 'Expected monthly volume',
                    value: s.expectedVolume,
                    placeholder: 'Tap to choose',
                    onTap: () async {
                      final v = await pushQPickPage<String>(
                        context,
                        title: 'Expected monthly volume',
                        options: _volumeOptions,
                        labelFor: (s) => s,
                        searchKeyFor: (s) => s,
                        selected: s.expectedVolume.isEmpty
                            ? null
                            : s.expectedVolume,
                      );
                      if (v != null) s.setExpectedVolume(v);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'High-risk industries (gambling, crypto, money services) need '
                    'a quick extra check — we\'ll flag it if so.',
                    style: QPayType.heroSub,
                  ),
                ],
              ),
            ),
            QBottomBar(
              child: QButton(
                label: 'Continue',
                onPressed: ok ? () => context.push('/banking-attest') : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickField extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  const _PickField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    return Material(
      color: QPayTokens.cardBase.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(QPayTokens.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QPayTokens.rCard),
            border: Border.all(
              color: empty ? QPayTokens.border : QPayTokens.borderStrong,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: QPayType.fieldLabel),
                    const SizedBox(height: 4),
                    Text(
                      empty ? placeholder : value,
                      style: QPayType.optionTitle.copyWith(
                        color: empty ? QPayTokens.ink4 : QPayTokens.ink,
                        fontWeight:
                            empty ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                empty ? Icons.add_rounded : Icons.chevron_right_rounded,
                color: QPayTokens.ink3,
                size: 22,
              ),
            ],
          ),
        ),
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
