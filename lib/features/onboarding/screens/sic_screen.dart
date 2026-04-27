import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';

/// A-06 · SIC code picker. Lives inside [OnboardingShell].
/// Natural-language search, AI suggests up to 3 codes, user can multi-select
/// up to 4. Tag-line above each card switches between accent (SELECTED) and
/// neutral (SUGGESTED).
class SicScreen extends StatefulWidget {
  const SicScreen({super.key});

  @override
  State<SicScreen> createState() => _SicScreenState();
}

class _SicCode {
  final String code;
  final String label;
  const _SicCode(this.code, this.label);
}

class _SicScreenState extends State<SicScreen> {
  static const int _maxSelectable = 4;

  final TextEditingController _searchCtrl =
      TextEditingController(text: 'software design');

  // Suggested codes for the current query. In production these come from the
  // AI mapping endpoint; for now they're static and match the design comp.
  static const List<_SicCode> _suggestions = [
    _SicCode('62012', 'Business/domestic software dev'),
    _SicCode('74100', 'Specialised design activities'),
    _SicCode('70229', 'Other mgmt consultancy'),
  ];

  final Set<String> _selected = {'62012'};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(String code) {
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else if (_selected.length < _maxSelectable) {
        _selected.add(code);
      }
    });
  }

  String _ctaLabel() {
    final n = _selected.length;
    if (n == 0) return 'Pick at least one';
    if (n == 1) return 'Continue with 1 code';
    return 'Continue with $n codes';
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.isNotEmpty;
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: _ctaLabel(),
          onPressed:
              canContinue ? () => context.push('/registered-office') : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'What will\nyou do?',
            subtitle:
                'Pick up to 4 SIC codes. We\'ll suggest the most relevant.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              controller: _searchCtrl,
              placeholder: 'Describe what you do',
              prefix: const Icon(
                Icons.search_rounded,
                size: 20,
                color: QPayTokens.ink3,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: QPayTokens.s5),
          ..._suggestions.map((s) {
            final selected = _selected.contains(s.code);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s4),
              child: QChoiceCard(
                tag:
                    '${selected ? "SELECTED" : "SUGGESTED"}  ·  ${s.code}',
                tagAccent: selected,
                title: s.label,
                selected: selected,
                onTap: () => _toggle(s.code),
              ),
            );
          }),
          const SizedBox(height: QPayTokens.s4),
        ],
      ),
    );
  }
}
