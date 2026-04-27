import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/widgets/q_progress_bar.dart';

/// Persistent chrome around screens A-02 … A-05 of the onboarding flow.
///
/// The top area (back arrow + progress indicator) is rendered by the shell
/// and stays put between route changes, so the stepper simply updates its
/// `step` count while the body cross-fades underneath.
class OnboardingShell extends StatelessWidget {
  final Widget child;

  /// Current route path, used to look up the matching step number.
  final String location;

  const OnboardingShell({
    super.key,
    required this.child,
    required this.location,
  });

  // Keep in sync with the GoRouter paths in app.dart.
  static const Map<String, int> _steps = {
    '/intent': 1,
    '/preflight': 2,
    '/solo': 3,
    '/name': 4,
    '/sic': 5,
    '/registered-office': 6,
    '/postcode': 6,
    '/address-confirm': 6,
    '/address-manual': 6,
    '/articles': 7,
  };

  static const int _total = 9;

  @override
  Widget build(BuildContext context) {
    final step = _steps[location] ?? 0;
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      // Root tap dismisses the keyboard anywhere on the page.
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QProgressBar(
                step: step,
                total: _total,
                onBack: () => _goBack(context),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Shell is the bottom of the stack → fall back to signup entry.
      context.go('/signup');
    }
  }
}
