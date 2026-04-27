import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';

/// A-02 · Pick your path. Lives inside [OnboardingShell].
class IntentScreen extends StatefulWidget {
  const IntentScreen({super.key});

  @override
  State<IntentScreen> createState() => _IntentScreenState();
}

class _IntentScreenState extends State<IntentScreen> {
  static const _options = <(String, String)>[
    (
      'Form a new Ltd company',
      '10 min · £0 · certificate + business account in one flow',
    ),
    (
      'I already have a Ltd — open an account',
      "We'll pull your details from Companies House",
    ),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: () => context.push('/preflight'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'What brings you\nto QPay?',
            subtitle: 'Pick what fits.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                for (var i = 0; i < _options.length; i++) ...[
                  QChoiceCard(
                    title: _options[i].$1,
                    subtitle: _options[i].$2,
                    selected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
                  if (i != _options.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}
