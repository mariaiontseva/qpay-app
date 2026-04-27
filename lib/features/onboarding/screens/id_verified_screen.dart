import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-13 · Verified · personal code. Top-level route.
/// Mock success state — in production the code is returned by the
/// verification provider (or by Companies House for the direct path).
class IdVerifiedScreen extends StatelessWidget {
  const IdVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: () => context.push('/form'),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: QPayTokens.successBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  color: QPayTokens.success,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Verified.',
              textAlign: TextAlign.center,
              style: QPayType.heroTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Companies House personal code is ready. It works for any UK director appointment, for life.',
              textAlign: TextAlign.center,
              style: QPayType.heroSub,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                color: QPayTokens.successBg,
                borderRadius: BorderRadius.circular(QPayTokens.rCard),
                border: Border.all(color: QPayTokens.success, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERSONAL CODE',
                          style: QPayType.fieldLabel
                              .copyWith(color: QPayTokens.success),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'XYZ123ABCD',
                          style: QPayType.optionTitle.copyWith(
                            fontFamily: 'JetBrainsMono',
                            letterSpacing: 0.08 * 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.copy_rounded,
                    color: QPayTokens.success,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
