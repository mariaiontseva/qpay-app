import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/formation_state.dart';

/// A-07 · Registered office choice. Lives inside [OnboardingShell].
/// Picking "My own address" + Continue enters the A-07A postcode sub-flow.
/// Email is collected separately on signup.
enum _OfficeChoice { qpay, own }

class RegisteredOfficeScreen extends StatefulWidget {
  const RegisteredOfficeScreen({super.key});

  @override
  State<RegisteredOfficeScreen> createState() =>
      _RegisteredOfficeScreenState();
}

class _RegisteredOfficeScreenState extends State<RegisteredOfficeScreen> {
  _OfficeChoice _choice = _OfficeChoice.qpay;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final s = FormationProvider.read(context);
    _choice = s.useQPayOffice ? _OfficeChoice.qpay : _OfficeChoice.own;
  }

  void _onContinue() {
    final s = FormationProvider.read(context);
    if (_choice == _OfficeChoice.qpay) {
      s.useQPayOfficeChoice();
      context.push('/articles');
    } else {
      // Don't overwrite ownAddress yet — postcode/manual screens will set it.
      context.push('/postcode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: _onContinue,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Registered\noffice.',
            subtitle: 'Companies House mails legal post here. It\'s public.',
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
                  "We'll find it from your postcode. Becomes public.",
              selected: _choice == _OfficeChoice.own,
              onTap: () => setState(() => _choice = _OfficeChoice.own),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}
