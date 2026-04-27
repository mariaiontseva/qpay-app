import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/formation_state.dart';

/// B-02 · Confirm CH-pulled details.
/// Auto-filled from the lookup. User confirms before any verification
/// runs.
class ExistingConfirmScreen extends StatelessWidget {
  const ExistingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: "Yes, that's mine",
          onPressed: () => context.push('/director-details'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Is this you?',
            subtitle:
                'Pulled from the Companies House public register. Tap any line to flag it as wrong.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Row(label: 'Name', value: s.companyName),
                _Row(
                  label: 'Number · Status',
                  value:
                      '${s.existingCompanyNumber} · ${_titleCase(s.existingStatus)}',
                  mono: true,
                ),
                if (s.existingIncorporationDate.isNotEmpty)
                  _Row(
                    label: 'Incorporated',
                    value: s.existingIncorporationDate,
                  ),
                if (s.existingJurisdiction.isNotEmpty)
                  _Row(
                    label: 'Jurisdiction',
                    value: s.existingJurisdiction,
                  ),
                if (s.existingRegisteredOffice.isNotEmpty)
                  _Row(
                    label: 'Registered office',
                    value: s.existingRegisteredOffice,
                  ),
                if (s.existingSicCodes.isNotEmpty)
                  _Row(
                    label:
                        'SIC code${s.existingSicCodes.length == 1 ? '' : 's'}',
                    value: s.existingSicCodes.join(', '),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 0),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Something's wrong",
                style: QPayType.statusLineStrong,
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Row({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QPayTokens.s3),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: QPayTokens.cardBase.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(QPayTokens.rCard),
          border: Border.all(color: QPayTokens.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: QPayType.fieldLabel),
            const SizedBox(height: 4),
            Text(
              value,
              style: (mono ? QPayType.progressNum : QPayType.optionTitle)
                  .copyWith(
                color: QPayTokens.ink,
                fontSize: mono ? 14 : 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
