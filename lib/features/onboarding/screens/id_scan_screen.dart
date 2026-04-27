import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-11 · Scan ID document. Top-level route.
/// Mocked passport / DL scan — the document half of the AML-standard
/// doc + selfie pair. ACSP-route verification per ECCTA § 1110A.
class IdScanScreen extends StatelessWidget {
  const IdScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: 'Scan passport',
              onPressed: () => context.push('/id-selfie'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                'Use driving licence instead',
                style: QPayType.statusLineStrong,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          const QHeader(
            title: 'Verify your\nID.',
            subtitle:
                'QPay is your Authorised Corporate Service Provider — verification happens right here. ECCTA-compliant, 1 minute.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: QPayTokens.successBg,
                borderRadius: BorderRadius.circular(QPayTokens.rPill),
              ),
              child: Text(
                '✓ QPay · Authorised by Companies House',
                textAlign: TextAlign.center,
                style: QPayType.statusLineStrong
                    .copyWith(color: QPayTokens.success, fontSize: 12.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: QPayTokens.borderStrong,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  color: QPayTokens.cardBase,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: QPayTokens.ink3,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: const Text('📕', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 220,
                        child: Text(
                          'Hold passport flat. Photo + chip side visible.',
                          textAlign: TextAlign.center,
                          style: QPayType.statusLine,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

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
