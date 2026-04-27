import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/sic_service.dart';

/// A-06 · SIC code picker. Lives inside [OnboardingShell].
/// Real keyword search across the 731 UK SIC 2007 codes, multi-select up
/// to 4. Selected codes always show first; remaining slots filled with
/// search suggestions ranked by token overlap.
class SicScreen extends StatefulWidget {
  const SicScreen({super.key});

  @override
  State<SicScreen> createState() => _SicScreenState();
}

class _SicScreenState extends State<SicScreen> {
  static const int _maxSelectable = 4;
  static const Duration _debounce = Duration(milliseconds: 220);

  final TextEditingController _searchCtrl = TextEditingController();
  final SicService _service = SicService();

  // Code → description, so we can render selected items even when they fall
  // outside the current search results.
  final Map<String, String> _selected = {};

  Timer? _debounceTimer;
  int _reqSeq = 0;
  bool _searching = false;
  List<SicCode> _results = const [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final q = _searchCtrl.text.trim();
    setState(() {
      if (q.isEmpty) {
        _results = const [];
        _searching = false;
      } else {
        _searching = true;
      }
    });
    if (q.isEmpty) return;
    _debounceTimer = Timer(_debounce, _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    final seq = ++_reqSeq;
    final res = await _service.search(q, limit: 8);
    if (!mounted || seq != _reqSeq) return;
    setState(() {
      _results = res;
      _searching = false;
    });
  }

  void _toggle(SicCode c) {
    setState(() {
      if (_selected.containsKey(c.code)) {
        _selected.remove(c.code);
      } else if (_selected.length < _maxSelectable) {
        _selected[c.code] = c.description;
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
    // Build display list: every selected code first, then any non-selected
    // search results — capped so the screen stays scrollable but not bloated.
    final displayed = <_Row>[];
    for (final entry in _selected.entries) {
      displayed.add(_Row(
        code: entry.key,
        description: entry.value,
        selected: true,
      ));
    }
    for (final r in _results) {
      if (_selected.containsKey(r.code)) continue;
      displayed.add(_Row(
        code: r.code,
        description: r.description,
        selected: false,
      ));
    }

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
                'Pick up to 4 SIC codes. Search by what your business does.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              controller: _searchCtrl,
              placeholder: 'e.g. software, design, consulting',
              prefix: const Icon(
                Icons.search_rounded,
                size: 20,
                color: QPayTokens.ink3,
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s5),
          if (_searching && _results.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: QPayTokens.ink3,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Searching…',
                      style: TextStyle(color: QPayTokens.ink3, fontSize: 13)),
                ],
              ),
            ),
          if (!_searching &&
              _searchCtrl.text.trim().isNotEmpty &&
              _results.isEmpty &&
              displayed.where((r) => !r.selected).isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Text(
                'No matches. Try a different word.',
                style: QPayType.optionSub,
              ),
            ),
          ...displayed.map((row) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s4),
              child: QChoiceCard(
                tag:
                    '${row.selected ? "SELECTED" : "MATCH"}  ·  ${row.code}',
                tagAccent: row.selected,
                title: row.description,
                selected: row.selected,
                onTap: () => _toggle(SicCode(row.code, row.description)),
              ),
            );
          }),
          const SizedBox(height: QPayTokens.s4),
        ],
      ),
    );
  }
}

class _Row {
  final String code;
  final String description;
  final bool selected;
  const _Row({
    required this.code,
    required this.description,
    required this.selected,
  });
}
