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

/// Returning-user entry point. Same passwordless email-OTP flow as
/// [SignupScreen] but with "welcome back" copy and a pointer to signup
/// for anyone who hit it by accident.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  static final _emailRe = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');

  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

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
      context.push('/verify',
          extra: <String, String>{'email': email, 'returning': 'true'});
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
              label: _busy ? 'Sending…' : 'Send sign-in code',
              onPressed: _allValid ? _sendCode : null,
            ),
            const SizedBox(height: QPayTokens.s4),
            Center(
              child: TextButton(
                onPressed: () => context.go('/signup'),
                style: TextButton.styleFrom(
                  foregroundColor: QPayTokens.ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: QPayTokens.s5,
                    vertical: QPayTokens.s3,
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    style: QPayType.termsFooter,
                    children: [
                      const TextSpan(text: 'New here? '),
                      TextSpan(
                        text: 'Create an account',
                        style: QPayType.termsFooterStrong,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 24, 0),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back.', style: QPayType.heroTitle),
                const SizedBox(height: QPayTokens.s3),
                Text(
                  "Enter your email — we'll send an 8-digit sign-in code.",
                  style: QPayType.heroSub,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: QField(
              label: 'Email',
              controller: _email,
              placeholder: 'you@example.com',
              autofillHint: AutofillHints.email,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
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
