import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Top-of-screen row used from S02 onwards:
/// back arrow  ─  animated progress bar  ─  "N/T" mono label
class QProgressBar extends StatelessWidget {
  final VoidCallback? onBack;
  final int step;
  final int total;

  const QProgressBar({
    super.key,
    required this.step,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (step / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QPayTokens.s5,
        QPayTokens.s3 + 2,
        QPayTokens.s6,
        0,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: QPayTokens.s4 + 2),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(QPayTokens.rPill),
              child: SizedBox(
                height: 4,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x14000000),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        widthFactor: fraction,
                        heightFactor: 1,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: QPayTokens.ink,
                            borderRadius:
                                BorderRadius.all(Radius.circular(QPayTokens.rPill)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: QPayTokens.s4 + 2),
          Text('$step/$total', style: QPayType.progressNum),
        ],
      ),
    );
  }
}
