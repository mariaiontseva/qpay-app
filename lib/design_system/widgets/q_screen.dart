import 'package:flutter/material.dart';

import '../tokens.dart';

/// Warm-canvas scaffold shared by every QPay screen.
///
/// - [child] is scrollable by default
/// - [bottom] pins to the bottom inside the safe area (typically the CTA)
/// - [ambient] adds subtle peach / pink / yellow radial glows used on hero
///   screens (S01, S03, S08, …). Off by default for calmer screens.
class QScreen extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  final bool ambient;

  const QScreen({
    super.key,
    required this.child,
    this.bottom,
    this.ambient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            if (ambient) const Positioned.fill(child: _AmbientBackground()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: child,
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    // Three stacked radial gradients — peach (top-right), pink (left),
    // yellow (bottom). Matches the QAmbient helper in qpay-tokens.jsx.
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.6, -0.85),
                radius: 0.9,
                colors: [
                  QPayTokens.accent.withValues(alpha: 0.14),
                  QPayTokens.accent.withValues(alpha: 0),
                ],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.35),
                radius: 0.8,
                colors: [
                  QPayTokens.accentPink.withValues(alpha: 0.09),
                  QPayTokens.accentPink.withValues(alpha: 0),
                ],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.6),
                radius: 0.7,
                colors: [
                  QPayTokens.accentYellow.withValues(alpha: 0.11),
                  QPayTokens.accentYellow.withValues(alpha: 0),
                ],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
