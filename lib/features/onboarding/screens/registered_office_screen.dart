import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';

/// A-07 · Registered office + private email. Lives inside [OnboardingShell].
/// Two cards: QPay's London office (free, default) or your own address
/// (postcode auto-detects E&W / Scotland / NI jurisdiction). Private email
/// is where Companies House correspondence digests are forwarded.
enum _OfficeChoice { qpay, own }

class RegisteredOfficeScreen extends StatefulWidget {
  const RegisteredOfficeScreen({super.key});

  @override
  State<RegisteredOfficeScreen> createState() => _RegisteredOfficeScreenState();
}

class _RegisteredOfficeScreenState extends State<RegisteredOfficeScreen> {
  _OfficeChoice _choice = _OfficeChoice.qpay;
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isEmailValid(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    final at = s.indexOf('@');
    if (at <= 0 || at == s.length - 1) return false;
    final dot = s.indexOf('.', at);
    return dot > at + 1 && dot < s.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _isEmailValid(_emailCtrl.text);
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: canContinue ? () => context.push('/articles') : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Registered\noffice.',
            subtitle:
                'Companies House mails legal post here. It\'s public.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, QPayTokens.s4),
            child: QChoiceCard(
              title: "QPay's London address",
              subtitle: 'Office 1.01, 411 Oxford St · included free',
              selected: _choice == _OfficeChoice.qpay,
              onTap: () => setState(() => _choice = _OfficeChoice.qpay),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s4),
            child: QChoiceCard(
              title: 'My own address',
              subtitle:
                  "We'll set jurisdiction by postcode. Becomes public.",
              selected: _choice == _OfficeChoice.own,
              onTap: () => setState(() => _choice = _OfficeChoice.own),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, QPayTokens.s5, 24, 0),
            child: QField(
              label: 'PRIVATE EMAIL',
              controller: _emailCtrl,
              placeholder: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              autofillHint: 'email',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}
