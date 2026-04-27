import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'design_system/tokens.dart';
import 'features/onboarding/onboarding_shell.dart';
import 'features/onboarding/screens/address_confirm_screen.dart';
import 'features/onboarding/screens/address_manual_screen.dart';
import 'features/banking/banking_aml_screen.dart';
import 'features/banking/banking_attest_screen.dart';
import 'features/banking/banking_open_screen.dart';
import 'features/banking/banking_psc_screen.dart';
import 'features/banking/open_banking_screen.dart';
import 'features/home/home_shell.dart';
import 'features/home/profile_screen.dart';
import 'features/onboarding/screens/existing_lookup_screen.dart';
import 'features/onboarding/screens/articles_screen.dart';
import 'features/onboarding/screens/co_directors_screen.dart';
import 'features/onboarding/screens/director_details_screen.dart';
import 'features/onboarding/screens/email_screen.dart';
import 'features/onboarding/screens/filing_screen.dart';
import 'features/onboarding/screens/form_screen.dart';
import 'features/onboarding/screens/id_scan_screen.dart';
import 'features/onboarding/screens/id_selfie_screen.dart';
import 'features/onboarding/screens/id_verified_screen.dart';
import 'features/onboarding/screens/intent_screen.dart';
import 'features/onboarding/screens/live_screen.dart';
import 'features/onboarding/screens/name_screen.dart';
import 'features/onboarding/screens/postcode_screen.dart';
import 'features/onboarding/screens/preflight_screen.dart';
import 'features/onboarding/screens/registered_office_screen.dart';
import 'features/onboarding/screens/sic_screen.dart';
import 'features/onboarding/screens/summary_screen.dart';
import 'services/address_service.dart';
import 'features/onboarding/screens/signin_screen.dart';
import 'features/onboarding/screens/signup_screen.dart';
import 'features/onboarding/screens/solo_screen.dart';
import 'features/onboarding/screens/verify_otp_screen.dart';
import 'services/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/backend_provider.dart';
import 'services/backend_service.dart';
import 'services/companies_house_provider.dart';
import 'services/companies_house_service.dart';
import 'services/formation_state.dart';

/// iOS-style horizontal slide for top-level routes (/signup ↔ /verify).
CupertinoPage<void> _slidePage(Widget child) => CupertinoPage<void>(
      child: child,
    );

/// 180-ms cross-fade used between the four screens inside [OnboardingShell].
/// The shell (top bar + progress indicator) stays put; only the body fades.
CustomTransitionPage<void> _innerFade(Widget child) =>
    CustomTransitionPage<void>(
      child: child,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

final GoRouter _router = GoRouter(
  initialLocation: '/signup',
  routes: <RouteBase>[
    GoRoute(
      path: '/signup',
      pageBuilder: (_, __) => _slidePage(const SignupScreen()),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (_, __) => _slidePage(const SignInScreen()),
    ),
    GoRoute(
      path: '/verify',
      pageBuilder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return _slidePage(
          VerifyOtpScreen(
            email: extra['email'] ?? '',
            name: extra['name'] ?? '',
            returning: extra['returning'] == 'true',
          ),
        );
      },
    ),
    GoRoute(
      path: '/email',
      pageBuilder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return _slidePage(EmailScreen(name: extra['name'] ?? ''));
      },
    ),
    GoRoute(
      path: '/id-scan',
      pageBuilder: (_, __) => _slidePage(const IdScanScreen()),
    ),
    GoRoute(
      path: '/id-selfie',
      pageBuilder: (_, __) => _slidePage(const IdSelfieScreen()),
    ),
    GoRoute(
      path: '/id-verified',
      pageBuilder: (_, __) => _slidePage(const IdVerifiedScreen()),
    ),
    GoRoute(
      path: '/form',
      pageBuilder: (_, __) => _slidePage(const FormScreen()),
    ),
    GoRoute(
      path: '/filing',
      pageBuilder: (_, __) => _slidePage(const FilingScreen()),
    ),
    GoRoute(
      path: '/live',
      pageBuilder: (_, __) => _slidePage(const LiveScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (_, __) => _slidePage(const HomeShell()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (_, __) => _slidePage(const ProfileScreen()),
    ),
    GoRoute(
      path: '/existing-lookup',
      pageBuilder: (_, __) => _slidePage(const ExistingLookupScreen()),
    ),
    GoRoute(
      path: '/banking-psc',
      pageBuilder: (_, __) => _slidePage(const BankingPscScreen()),
    ),
    GoRoute(
      path: '/banking-aml',
      pageBuilder: (_, __) => _slidePage(const BankingAmlScreen()),
    ),
    GoRoute(
      path: '/banking-attest',
      pageBuilder: (_, __) => _slidePage(const BankingAttestScreen()),
    ),
    GoRoute(
      path: '/banking-open',
      pageBuilder: (_, __) => _slidePage(const BankingOpenScreen()),
    ),
    GoRoute(
      path: '/banking-connect',
      pageBuilder: (_, __) => _slidePage(const OpenBankingScreen()),
    ),
    // Persistent onboarding chrome (back arrow + progress bar) wraps the
    // A-02…A-05 screens. `NoTransitionPage` keeps the shell in place while
    // each nested route cross-fades with `_innerFade`.
    ShellRoute(
      pageBuilder: (context, state, child) => NoTransitionPage(
        child: OnboardingShell(
          location: state.uri.path,
          child: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/intent',
          pageBuilder: (_, __) => _innerFade(const IntentScreen()),
        ),
        GoRoute(
          path: '/preflight',
          pageBuilder: (_, __) => _innerFade(const PreflightScreen()),
        ),
        GoRoute(
          path: '/solo',
          pageBuilder: (_, __) => _innerFade(const SoloScreen()),
        ),
        GoRoute(
          path: '/name',
          pageBuilder: (_, __) => _innerFade(const NameScreen()),
        ),
        GoRoute(
          path: '/sic',
          pageBuilder: (_, __) => _innerFade(const SicScreen()),
        ),
        GoRoute(
          path: '/registered-office',
          pageBuilder: (_, __) => _innerFade(const RegisteredOfficeScreen()),
        ),
        GoRoute(
          path: '/postcode',
          pageBuilder: (_, __) => _innerFade(const PostcodeScreen()),
        ),
        GoRoute(
          path: '/address-confirm',
          pageBuilder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            final address = extra['address'] as UkAddress?;
            if (address == null) {
              return _innerFade(const PostcodeScreen());
            }
            return _innerFade(AddressConfirmScreen(address: address));
          },
        ),
        GoRoute(
          path: '/address-manual',
          pageBuilder: (_, state) {
            final extra = state.extra as Map<String, dynamic>? ?? const {};
            return _innerFade(AddressManualScreen(
              prefill: extra['prefill'] as UkAddress?,
              prefillPostcode: extra['prefillPostcode'] as String?,
            ));
          },
        ),
        GoRoute(
          path: '/articles',
          pageBuilder: (_, __) => _innerFade(const ArticlesScreen()),
        ),
        GoRoute(
          path: '/summary',
          pageBuilder: (_, __) => _innerFade(const SummaryScreen()),
        ),
        GoRoute(
          path: '/director-details',
          pageBuilder: (_, __) => _innerFade(const DirectorDetailsScreen()),
        ),
        GoRoute(
          path: '/co-directors',
          pageBuilder: (_, __) => _innerFade(const CoDirectorsScreen()),
        ),
      ],
    ),
  ],
);

class QPayApp extends StatelessWidget {
  final AuthService authService;
  final CompaniesHouseService companiesHouseService;
  final BackendService backendService;
  final FormationState formationState;

  const QPayApp({
    super.key,
    required this.authService,
    required this.companiesHouseService,
    required this.backendService,
    required this.formationState,
  });

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
    return FormationProvider(
      state: formationState,
      child: AuthProvider(
      service: authService,
      child: CompaniesHouseProvider(
        service: companiesHouseService,
        child: BackendProvider(
          service: backendService,
          child: MaterialApp.router(
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
          ),
        ),
      ),
      ),
    );
  }
}
