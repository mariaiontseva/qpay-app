import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/auth_provider.dart';
import '../../../services/formation_state.dart';

/// A-01b · Sign up step 2: email.
/// Receives the name via go_router extra. CTA fires the Supabase email-OTP
/// and navigates to /verify with both name and email so the OTP screen can
/// persist them together.
class EmailScreen extends StatefulWidget {
  final String name;

  const EmailScreen({super.key, required this.name});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  static final _emailRe = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');

  final _email = TextEditingController();
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

  bool get _ok => _emailRe.hasMatch(_email.text.trim()) && !_busy;

  Future<void> _onContinue() async {
    if (!_ok) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim();
    FormationProvider.read(context).setUserEmail(email);
    try {
      await AuthProvider.of(context).sendOtp(email);
      if (!mounted) return;
      context.push('/verify',
          extra: <String, String>{'email': email, 'name': widget.name});
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
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QButton(
              label: _busy ? 'Sending…' : 'Send verification code',
              onPressed: _ok ? _onContinue : null,
            ),
            const SizedBox(height: QPayTokens.s4),
            const Center(child: _TermsFooter()),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BackBar(),
          QHeader(
            title: 'And your\nemail?',
            subtitle: widget.name.isNotEmpty
                ? "Hi ${widget.name.split(' ').first}. We'll send you an 8-digit code."
                : "We'll send you an 8-digit code.",
            topPadding: 24,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: QField(
              controller: _email,
              placeholder: 'you@example.com',
              autofillHint: AutofillHints.email,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
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

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(QPayTokens.s5, 10, QPayTokens.s6, 0),
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
