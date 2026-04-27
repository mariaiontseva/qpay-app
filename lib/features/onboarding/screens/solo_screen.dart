import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/formation_state.dart';

/// A-04 · Solo or team? Lives inside [OnboardingShell].
class SoloScreen extends StatefulWidget {
  const SoloScreen({super.key});

  @override
  State<SoloScreen> createState() => _SoloScreenState();
}

class _SoloScreenState extends State<SoloScreen> {
  static const _options = <(String, String)>[
    (
      'Just me',
      '1 director · 100 shares · 1 PSC — all you. 92% of Ltds start this way.',
    ),
    (
      'Co-founders or investors',
      "We'll ask about shares and PSCs on the next screens.",
    ),
  ];

  int _selected = 0;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    _selected = FormationProvider.read(context).isSolo ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: () {
            FormationProvider.read(context).setIsSolo(_selected == 0);
            context.push('/name');
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Is this just you,\nor a team?',
            subtitle: 'You can add co-founders or re-issue shares later.',
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
