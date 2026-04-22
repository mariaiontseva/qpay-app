import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-01 · Sign up for QPay.
/// Name, email, +44 mobile. Primary CTA sends the verification code.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      ambient: true,
      bottom: QBottomBar(
        child: QButton(
          label: 'Send verification code',
          onPressed: () => context.push('/intent'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TopBar(),
          const _Hero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QField(
                  label: 'Full name',
                  controller: _name,
                  placeholder: 'Your name',
                  autofillHint: AutofillHints.name,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 10),
                QField(
                  label: 'Email',
                  controller: _email,
                  placeholder: 'you@example.com',
                  autofillHint: AutofillHints.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                QField(
                  label: 'Mobile',
                  controller: _phone,
                  placeholder: '7123 456789',
                  hint: "We'll text a 6-digit code",
                  autofillHint: AutofillHints.telephoneNumberNational,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  ],
                  prefix: const _GbPrefix(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: _TermsFooter(),
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
          Text('QPay', style: QPayType.wordmark),
          const Spacer(),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: QPayTokens.cardBase.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(QPayTokens.rPill),
              border: Border.all(color: QPayTokens.border),
            ),
            child: Text('Sign in', style: QPayType.signInChip),
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 4),
      child: _HeroText(),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Business banking, next level.', style: QPayType.heroTitle),
        const SizedBox(height: QPayTokens.s3),
        Text(
          'Form your Ltd and open your account in one go.',
          style: QPayType.heroSub,
        ),
      ],
    );
  }
}

class _GbPrefix extends StatelessWidget {
  const _GbPrefix();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🇬🇧', style: TextStyle(fontSize: 16, height: 1)),
        const SizedBox(width: 6),
        Text('+44', style: QPayType.fieldPrefix),
      ],
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
    );
  }
}
