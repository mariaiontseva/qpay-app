import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/address_service.dart';

/// A-07C · Confirm address.
/// Final review of the building the user picked. "Use this address" advances
/// the flow to /articles. "Pick another" pops back to the results list.
class AddressConfirmScreen extends StatelessWidget {
  final UkAddress address;

  const AddressConfirmScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Use this address',
          onPressed: () => context.go('/articles'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Is this right?',
            subtitle:
                'This becomes your registered office and is public.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _AddressCard(address: address),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Text.rich(
              TextSpan(
                style: QPayType.statusLine.copyWith(color: QPayTokens.ink2),
                children: [
                  const TextSpan(text: 'Wrong building? '),
                  TextSpan(
                    text: 'Pick another.',
                    style: QPayType.statusLineStrong,
                    recognizer: null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final UkAddress address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTERED OFFICE',
            style: QPayType.progressNum.copyWith(color: QPayTokens.ink3),
          ),
          const SizedBox(height: 8),
          Text(address.line1,
              style: QPayType.heroTitle.copyWith(fontSize: 22, height: 1.15)),
          const SizedBox(height: 6),
          Text(address.locality, style: QPayType.optionTitle),
          Text(address.postcode, style: QPayType.optionTitle),
          const SizedBox(height: 14),
          const Row(
            children: [
              _Chip(label: 'Public', tone: _ChipTone.neutral),
              SizedBox(width: 8),
              _Chip(label: 'Validated', tone: _ChipTone.success),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ChipTone { neutral, success }

class _Chip extends StatelessWidget {
  final String label;
  final _ChipTone tone;
  const _Chip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _ChipTone.success => (QPayTokens.successBg, QPayTokens.success),
      _ChipTone.neutral => (QPayTokens.n100, QPayTokens.ink2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
      ),
      child: Text(
        label,
        style: QPayType.optionSub.copyWith(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
