import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'design_system/tokens.dart';
import 'features/onboarding/screens/intent_screen.dart';
import 'features/onboarding/screens/name_screen.dart';
import 'features/onboarding/screens/preflight_screen.dart';
import 'features/onboarding/screens/signup_screen.dart';
import 'features/onboarding/screens/solo_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/signup',
  routes: <RouteBase>[
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: '/intent',
      builder: (_, __) => const IntentScreen(),
    ),
    GoRoute(
      path: '/preflight',
      builder: (_, __) => const PreflightScreen(),
    ),
    GoRoute(
      path: '/solo',
      builder: (_, __) => const SoloScreen(),
    ),
    GoRoute(
      path: '/name',
      builder: (_, __) => const NameScreen(),
    ),
  ],
);

class QPayApp extends StatelessWidget {
  const QPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: QPayTokens.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp.router(
      title: 'QPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: QPayTokens.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: QPayTokens.accent,
          primary: QPayTokens.ink,
          surface: QPayTokens.canvas,
        ),
        splashFactory: InkRipple.splashFactory,
      ),
      routerConfig: _router,
    );
  }
}
