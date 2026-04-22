import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_progress_bar.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-04 · Solo or team?
/// Default: "Just me" — 92 % of Ltds start this way.
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

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: () => context.push('/name'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QProgressBar(step: 3, total: 9, onBack: () => context.pop()),
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
