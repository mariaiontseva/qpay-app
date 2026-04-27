import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-12 · Liveness selfie. Top-level route.
/// Biometric face-match required by the Companies House identity
/// verification standard (ACSPs must meet One Login level of assurance).
class IdSelfieScreen extends StatelessWidget {
  const IdSelfieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Capture',
          onPressed: () => context.push('/id-verified'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          const QHeader(
            title: 'Quick selfie.',
            subtitle:
                'Companies House requires a biometric face-match against your document. No glasses, good lighting.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: AspectRatio(
              aspectRatio: 0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: QPayTokens.borderStrong,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  color: QPayTokens.cardBase,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: QPayTokens.ink3,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🙂', style: TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 220,
                        child: Text(
                          "Look at the camera. We'll capture a couple of frames automatically.",
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
