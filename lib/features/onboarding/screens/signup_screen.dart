import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/auth_provider.dart';

/// A-01 · Sign up for QPay.
/// Name, email, +44 mobile. CTA calls Supabase phone OTP and navigates to
/// the verification screen.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();

  static final _emailRe = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');

  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onChanged);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() => _error = null);

  bool get _emailOk => _emailRe.hasMatch(_email.text.trim());
  bool get _allValid => _emailOk && !_busy;

  Future<void> _sendCode() async {
    if (!_allValid) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim();
    try {
      await AuthProvider.of(context).sendOtp(email);
      if (!mounted) return;
      context.push('/verify', extra: <String, String>{'email': email});
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = '${e.statusCode ?? ''} ${e.message}'.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Network or unknown error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      ambient: true,
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: _busy ? 'Sending…' : 'Send verification code',
              onPressed: _allValid ? _sendCode : null,
            ),
            const SizedBox(height: QPayTokens.s4),
            const Center(child: _TermsFooter()),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TopBar(),
          const _Hero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: QField(
              label: 'Email',
              controller: _email,
              placeholder: 'you@example.com',
              hint: "We'll email you an 8-digit code",
              autofillHint: AutofillHints.email,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                _error!,
                style: QPayType.heroSub.copyWith(
                  color: QPayTokens.alert,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Row(
        children: [
          // Dev shortcut: long-press the wordmark to reset the navigation
          // stack to the first onboarding screen.
          GestureDetector(
            onLongPress: () => context.go('/signup'),
            child: Text('QPay', style: QPayType.wordmark),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(QPayTokens.rPill),
              onTap: () => context.push('/signin'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: QPayTokens.s3,
                  vertical: QPayTokens.s2 + 2,
                ),
                child: Text('Sign in', style: QPayType.signInChip),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business banking, next level.', style: QPayType.heroTitle),
          const SizedBox(height: QPayTokens.s3),
          Text(
            'Form your Ltd and open your account in one go.',
            style: QPayType.heroSub,
          ),
        ],
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: QPayType.termsFooter,
        children: [
          const TextSpan(text: "By continuing you agree to QPay's "),
          TextSpan(text: 'Terms', style: QPayType.termsFooterStrong),
          const TextSpan(text: ' & '),
          TextSpan(text: 'Privacy', style: QPayType.termsFooterStrong),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
