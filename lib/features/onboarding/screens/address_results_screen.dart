import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/address_service.dart';

/// A-07B · Address results.
/// Receives a postcode + list of addresses via go_router `extra`. Each row
/// is tappable and pushes /address-confirm with the selected address.
class AddressResultsScreen extends StatelessWidget {
  final String postcode;
  final List<UkAddress> addresses;

  const AddressResultsScreen({
    super.key,
    required this.postcode,
    required this.addresses,
  });

  @override
  Widget build(BuildContext context) {
    final n = addresses.length;
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Try a different postcode',
          kind: QButtonKind.primary,
          onPressed: () => context.pop(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Pick your\naddress.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text.rich(
              TextSpan(
                style: QPayType.heroSub,
                children: [
                  TextSpan(
                    text: '$n match${n == 1 ? '' : 'es'} ',
                    style: QPayType.heroSub
                        .copyWith(color: QPayTokens.ink, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: 'for $postcode'),
                ],
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s4),
          ...addresses.map((a) => Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s3),
                child: _AddressRow(
                  address: a,
                  onTap: () => context.push(
                    '/address-confirm',
                    extra: {'address': a},
                  ),
                ),
              )),
          const SizedBox(height: QPayTokens.s5),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final UkAddress address;
  final VoidCallback onTap;

  const _AddressRow({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QPayTokens.cardBase.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(QPayTokens.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QPayTokens.rCard),
            border: Border.all(color: QPayTokens.border, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.line1, style: QPayType.optionTitle),
                    const SizedBox(height: 4),
                    Text(
                      '${address.locality} · ${address.postcode}',
                      style: QPayType.optionSub,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
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
