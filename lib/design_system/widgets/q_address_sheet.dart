import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/address_service.dart';
import '../../services/postcode_service.dart';
import '../tokens.dart';
import '../typography.dart';
import 'q_button.dart';
import 'q_field.dart';

/// Modal bottom sheet for entering a UK address.
/// Tries postcode lookup first (Ideal Postcodes / Overpass via
/// AddressService); the user can pick a row, or fall back to manual
/// entry. Returns a single-line formatted address string, or null on
/// dismiss.
Future<String?> showQAddressSheet(
  BuildContext context, {
  required String title,
  String? initial,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: QPayTokens.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => _AddressSheet(title: title, initial: initial),
  );
}

class _AddressSheet extends StatefulWidget {
  final String title;
  final String? initial;
  const _AddressSheet({required this.title, this.initial});

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

enum _Mode { lookup, manual }

enum _LookupState { idle, searching, hasResults, noResults, error }

class _AddressSheetState extends State<_AddressSheet> {
  static const Duration _debounce = Duration(milliseconds: 350);

  _Mode _mode = _Mode.lookup;

  // Lookup
  final _postcodeCtrl = TextEditingController();
  final _service = AddressService();
  Timer? _timer;
  int _seq = 0;
  _LookupState _state = _LookupState.idle;
  List<UkAddress> _results = const [];
  String? _err;

  // Manual
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _town = TextEditingController();
  final _manualPostcode = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postcodeCtrl.addListener(_onPostcodeChanged);
    for (final c in [_line1, _line2, _town, _manualPostcode]) {
      c.addListener(() => setState(() {}));
    }
    if (widget.initial != null && widget.initial!.isNotEmpty) {
      // Pre-fill manual mode with the existing single-line value.
      _line1.text = widget.initial!;
      _mode = _Mode.manual;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _postcodeCtrl.dispose();
    _line1.dispose();
    _line2.dispose();
    _town.dispose();
    _manualPostcode.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onPostcodeChanged() {
    setState(() {
      _state = _LookupState.idle;
      _results = const [];
      _err = null;
    });
    _timer?.cancel();
    if (PostcodeService.isPlausible(_postcodeCtrl.text)) {
      _timer = Timer(_debounce, _runSearch);
    }
  }

  Future<void> _runSearch() async {
    final input = _postcodeCtrl.text.trim();
    if (!PostcodeService.isPlausible(input)) return;
    final s = ++_seq;
    setState(() => _state = _LookupState.searching);
    try {
      final r = await _service.findAddresses(input);
      if (!mounted || s != _seq) return;
      setState(() {
        _results = r;
        _state =
            r.isEmpty ? _LookupState.noResults : _LookupState.hasResults;
      });
    } catch (e) {
      if (!mounted || s != _seq) return;
      setState(() {
        _err = e.toString();
        _state = _LookupState.error;
      });
    }
  }

  void _pickAddress(UkAddress a) {
    final formatted = '${a.line1}, ${a.locality} ${a.postcode}';
    Navigator.of(context).pop(formatted);
  }

  void _saveManual() {
    final parts = <String>[
      if (_line2.text.trim().isNotEmpty) _line2.text.trim(),
      _line1.text.trim(),
      _town.text.trim(),
      _manualPostcode.text.trim().toUpperCase(),
    ].where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return;
    Navigator.of(context).pop(parts.join(', '));
  }

  bool get _manualOk =>
      _line1.text.trim().isNotEmpty &&
      _town.text.trim().isNotEmpty &&
      _manualPostcode.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.86;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: QPayTokens.n300,
                borderRadius: BorderRadius.circular(QPayTokens.rPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: QPayType.heroTitle.copyWith(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ModeToggle(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _mode == _Mode.lookup
                    ? _buildLookup()
                    : _buildManual(),
              ),
            ),
            if (_mode == _Mode.manual)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: QButton(
                  label: 'Save',
                  onPressed: _manualOk ? _saveManual : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QField(
          controller: _postcodeCtrl,
          placeholder: 'SW1A 1AA',
          autofillHint: 'postalCode',
          autofocus: true,
          prefix: const Icon(
            Icons.location_on_rounded,
            size: 20,
            color: QPayTokens.ink3,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
            LengthLimitingTextInputFormatter(8),
            _Upper(),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 22,
          child: _StatusLine(
            state: _state,
            postcode: _postcodeCtrl.text.trim().toUpperCase(),
            count: _results.length,
            err: _err,
          ),
        ),
        const SizedBox(height: 8),
        for (final a in _results)
          _AddressRow(address: a, onTap: () => _pickAddress(a)),
      ],
    );
  }

  Widget _buildManual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QField(
          controller: _line1,
          placeholder: '1 Buckingham Gate',
          label: 'BUILDING / STREET',
          autofocus: true,
        ),
        const SizedBox(height: 12),
        QField(
          controller: _line2,
          placeholder: 'Flat 4 (optional)',
          label: 'BUILDING NAME / FLAT',
        ),
        const SizedBox(height: 12),
        QField(
          controller: _town,
          placeholder: 'London',
          label: 'TOWN / CITY',
        ),
        const SizedBox(height: 12),
        QField(
          controller: _manualPostcode,
          placeholder: 'SW1A 1AA',
          label: 'POSTCODE',
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
            LengthLimitingTextInputFormatter(8),
            _Upper(),
          ],
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _Mode mode;
  final ValueChanged<_Mode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: QPayTokens.n100,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
      ),
      child: Row(
        children: [
          _segment('Postcode', _Mode.lookup),
          _segment('Manual', _Mode.manual),
        ],
      ),
    );
  }

  Widget _segment(String label, _Mode m) {
    final selected = mode == m;
    return Expanded(
      child: Material(
        color: selected ? QPayTokens.cardBase : Colors.transparent,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(QPayTokens.rPill),
          onTap: () => onChanged(m),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Center(
              child: Text(
                label,
                style: QPayType.optionTitle.copyWith(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? QPayTokens.ink : QPayTokens.ink3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final _LookupState state;
  final String postcode;
  final int count;
  final String? err;
  const _StatusLine({
    required this.state,
    required this.postcode,
    required this.count,
    required this.err,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _LookupState.idle:
        return const SizedBox.shrink();
      case _LookupState.searching:
        return Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: QPayTokens.ink3,
              ),
            ),
            const SizedBox(width: 10),
            Text('Looking up addresses…', style: QPayType.statusLine),
          ],
        );
      case _LookupState.hasResults:
        return Text.rich(
          TextSpan(
            style: QPayType.statusLine,
            children: [
              TextSpan(
                text: '$count match${count == 1 ? '' : 'es'} ',
                style: QPayType.statusLineStrong,
              ),
              TextSpan(text: 'for $postcode'),
            ],
          ),
        );
      case _LookupState.noResults:
        return Text(
          'No matches. Switch to Manual.',
          style: QPayType.statusLine,
        );
      case _LookupState.error:
        return Text(
          err ?? 'Lookup failed.',
          style: QPayType.statusLine.copyWith(color: QPayTokens.alert),
        );
    }
  }
}

class _AddressRow extends StatelessWidget {
  final UkAddress address;
  final VoidCallback onTap;
  const _AddressRow({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: QPayTokens.cardBase.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(QPayTokens.rCard),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QPayTokens.rCard),
              border: Border.all(color: QPayTokens.border, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.line1, style: QPayType.optionTitle),
                      const SizedBox(height: 4),
                      Text(
                        '${address.locality} · ${address.postcode}',
                        style: QPayType.optionSub,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: QPayTokens.ink3,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Upper extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
