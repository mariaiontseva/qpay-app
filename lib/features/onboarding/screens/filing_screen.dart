import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-15 · Filing in progress. Top-level route.
/// Mocked CH submission — auto-advances to /live after a short delay.
class FilingScreen extends StatefulWidget {
  const FilingScreen({super.key});

  @override
  State<FilingScreen> createState() => _FilingScreenState();
}

class _FilingScreenState extends State<FilingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/live');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: QPayTokens.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: QPayTokens.accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filing with\nCompanies House…',
              textAlign: TextAlign.center,
              style: QPayType.heroTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Usually under 30 seconds. We'll let you know the moment it's live.",
                textAlign: TextAlign.center,
                style: QPayType.heroSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
