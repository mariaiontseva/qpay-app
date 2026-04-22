import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_progress_bar.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-05 · Name your company.
/// Live availability line below the input; CTA disabled until ≥ 3 chars.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _ctrl =
      TextEditingController(text: 'Orca Design');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = _ctrl.text.trim();
    final ok = trimmed.length >= 3;
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: ok ? () {} : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QProgressBar(step: 4, total: 9, onBack: () => context.pop()),
          const QHeader(
            title: 'Name your\ncompany.',
            subtitle: 'We\'ll add "Ltd" at the end.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: QField(
              controller: _ctrl,
              placeholder: 'Your company',
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: SizedBox(
              height: 20,
              child: ok ? _AvailabilityLine(name: trimmed) : const SizedBox(),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _AvailabilityLine extends StatelessWidget {
  final String name;
  const _AvailabilityLine({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: QPayTokens.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: QPayTokens.s3),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: QPayType.statusLine,
              children: [
                TextSpan(
                  text: '$name Ltd',
                  style: QPayType.statusLineStrong,
                ),
                const TextSpan(text: ' is available'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
