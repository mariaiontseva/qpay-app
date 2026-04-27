import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-01 · Sign up step 1: full name.
/// One question per screen — the QHeader carries the prompt, the QField
/// has no label so the page reads like a single question.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _ok {
    final s = _name.text.trim();
    if (s.length < 2) return false;
    return s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length >= 2;
  }

  void _onContinue() {
    if (!_ok) return;
    context.push('/email', extra: {'name': _name.text.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: _ok ? _onContinue : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TopBar(),
          const QHeader(
            title: "What's your\nname?",
            subtitle:
                'Your full name goes on company paperwork, so make it official.',
            topPadding: 32,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: QField(
              controller: _name,
              placeholder: 'First and last',
              autofillHint: AutofillHints.name,
              keyboardType: TextInputType.name,
              autofocus: true,
              inputFormatters: [LengthLimitingTextInputFormatter(64)],
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
          // Dev shortcut: long-press the wordmark to jump straight into the
          // first onboarding step inside the shell, skipping auth.
          GestureDetector(
            onLongPress: () => context.push('/intent'),
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
