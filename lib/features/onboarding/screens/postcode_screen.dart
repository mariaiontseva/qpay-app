import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/address_service.dart';
import '../../../services/postcode_service.dart';

/// A-07A · Postcode lookup with inline results.
/// Lives inside [OnboardingShell] (step 6 / 9). The results list appears
/// directly under the postcode input as soon as a plausible UK postcode
/// is entered, so users skip a screen. Tapping a row pushes
/// /address-confirm; "Type address manually" is always available as a
/// secondary CTA in the bottom bar.
class PostcodeScreen extends StatefulWidget {
  const PostcodeScreen({super.key});

  @override
  State<PostcodeScreen> createState() => _PostcodeScreenState();
}

enum _LookupState { idle, searching, hasResults, noResults, error }

class _PostcodeScreenState extends State<PostcodeScreen> {
  static const Duration _debounce = Duration(milliseconds: 350);

  final TextEditingController _ctrl = TextEditingController();
  final AddressService _service = AddressService();

  Timer? _debounceTimer;
  int _reqSeq = 0;

  _LookupState _state = _LookupState.idle;
  List<UkAddress> _results = const [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.dispose();
    _service.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _state = _LookupState.idle;
      _results = const [];
      _errorMsg = null;
    });
    _debounceTimer?.cancel();
    if (PostcodeService.isPlausible(_ctrl.text)) {
      _debounceTimer = Timer(_debounce, _runSearch);
    }
  }

  Future<void> _runSearch() async {
    final input = _ctrl.text.trim();
    if (!PostcodeService.isPlausible(input)) return;
    final seq = ++_reqSeq;
    setState(() {
      _state = _LookupState.searching;
      _errorMsg = null;
    });
    try {
      final results = await _service.findAddresses(input);
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _results = results;
        _state = results.isEmpty
            ? _LookupState.noResults
            : _LookupState.hasResults;
      });
    } on PostcodeException catch (e) {
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _errorMsg = e.message;
        _state = _LookupState.error;
      });
    } catch (_) {
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _errorMsg = "Couldn't reach lookup. Try again.";
        _state = _LookupState.error;
      });
    }
  }

  void _onPickManual() {
    context.push(
      '/address-manual',
      extra: {'prefillPostcode': _ctrl.text.trim().toUpperCase()},
    );
  }

  void _onPick(UkAddress a) {
    context.push('/address-confirm', extra: {'address': a});
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Type address manually',
          kind: QButtonKind.secondary,
          onPressed: _onPickManual,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: "What's your\npostcode?",
            subtitle: "We'll find your address. UK only.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              controller: _ctrl,
              placeholder: 'SW1A 1AA',
              autofillHint: 'postalCode',
              keyboardType: TextInputType.text,
              autofocus: true,
              prefix: const Icon(
                Icons.location_on_rounded,
                size: 20,
                color: QPayTokens.ink3,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                LengthLimitingTextInputFormatter(8),
                _UppercaseFormatter(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _StatusBlock(
            state: _state,
            postcode: _ctrl.text.trim(),
            count: _results.length,
            errorMsg: _errorMsg,
          ),
          if (_state == _LookupState.hasResults) ...[
            const SizedBox(height: 4),
            ..._results.map(
              (a) => Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s3),
                child: _AddressRow(address: a, onTap: () => _onPick(a)),
              ),
            ),
          ],
          const SizedBox(height: QPayTokens.s5),
        ],
      ),
    );
  }
}

class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

class _StatusBlock extends StatelessWidget {
  final _LookupState state;
  final String postcode;
  final int count;
  final String? errorMsg;

  const _StatusBlock({
    required this.state,
    required this.postcode,
    required this.count,
    required this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(28, 0, 24, QPayTokens.s4);

    switch (state) {
      case _LookupState.idle:
        return const SizedBox(height: 8);
      case _LookupState.searching:
        return Padding(
          padding: padding,
          child: Row(
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
          ),
        );
      case _LookupState.hasResults:
        return Padding(
          padding: padding,
          child: Text.rich(
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
          ),
        );
      case _LookupState.noResults:
        return Padding(
          padding: padding,
          child: Row(
            children: [
              _dot(QPayTokens.alert),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No matches for $postcode. Type the address manually.',
                  style: QPayType.statusLine,
                ),
              ),
            ],
          ),
        );
      case _LookupState.error:
        return Padding(
          padding: padding,
          child: Row(
            children: [
              _dot(QPayTokens.warn),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMsg ?? "Couldn't check.",
                  style: QPayType.statusLine,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _dot(Color color) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _AddressRow extends StatelessWidget {
  final UkAddress address;
  final VoidCallback onTap;

  const _AddressRow({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: QPayTokens.cardBase.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(QPayTokens.rCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: QPayTokens.ink3,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
