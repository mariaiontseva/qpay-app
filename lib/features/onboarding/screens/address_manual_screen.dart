import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/address_service.dart';
import '../../../services/postcode_service.dart';

/// A-07D · Manual address entry.
/// Reachable via the "Edit manually" link on A-07B / A-07C, or directly when
/// the postcode lookup returns no curated matches. Validates the postcode
/// against postcodes.io to derive the CH jurisdiction; the rest of the
/// fields are user-entered.
class AddressManualScreen extends StatefulWidget {
  /// Optional starting values — we prefill these when the user is editing
  /// an address picked from the lookup or coming straight from /postcode.
  final UkAddress? prefill;
  final String? prefillPostcode;

  const AddressManualScreen({
    super.key,
    this.prefill,
    this.prefillPostcode,
  });

  @override
  State<AddressManualScreen> createState() => _AddressManualScreenState();
}

class _AddressManualScreenState extends State<AddressManualScreen> {
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _town;
  late final TextEditingController _postcode;

  final PostcodeService _postcodeService = PostcodeService();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    _line1 = TextEditingController(text: p?.line1 ?? '');
    _line2 = TextEditingController();
    _town = TextEditingController(text: p?.locality ?? '');
    _postcode = TextEditingController(
      text: p?.postcode ?? widget.prefillPostcode ?? '',
    );
    for (final c in [_line1, _line2, _town, _postcode]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _line1.dispose();
    _line2.dispose();
    _town.dispose();
    _postcode.dispose();
    _postcodeService.dispose();
    super.dispose();
  }

  bool get _looksValid =>
      _line1.text.trim().isNotEmpty &&
      _town.text.trim().isNotEmpty &&
      PostcodeService.isPlausible(_postcode.text);

  Future<void> _save() async {
    if (!_looksValid || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final pc = await _postcodeService.lookup(_postcode.text.trim());
      if (!mounted) return;
      final line1 = [
        if (_line2.text.trim().isNotEmpty) _line2.text.trim(),
        _line1.text.trim(),
      ].join(', ');
      final picked = UkAddress(
        line1: line1,
        locality: _town.text.trim(),
        postcode: pc.postcode,
        jurisdiction: pc.jurisdiction,
      );
      context.go('/address-confirm', extra: {'address': picked});
    } on PostcodeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = "Couldn't validate postcode. Try again.",
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: _saving ? 'Saving…' : 'Save address',
          onPressed: _looksValid && !_saving ? _save : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Type your\naddress.',
            subtitle:
                "We couldn't find it automatically. Enter it the way it should appear on the public register.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                QField(
                  label: 'BUILDING / STREET',
                  controller: _line1,
                  placeholder: '1 Buckingham Gate',
                  autofillHint: 'streetAddressLine1',
                ),
                const SizedBox(height: 14),
                QField(
                  label: 'BUILDING NAME / FLAT (OPTIONAL)',
                  controller: _line2,
                  placeholder: 'Stable Yard House, Flat 4',
                  autofillHint: 'streetAddressLine2',
                ),
                const SizedBox(height: 14),
                QField(
                  label: 'TOWN / CITY',
                  controller: _town,
                  placeholder: 'London',
                  autofillHint: 'addressCity',
                ),
                const SizedBox(height: 14),
                QField(
                  label: 'POSTCODE',
                  controller: _postcode,
                  placeholder: 'SW1A 1AA',
                  autofillHint: 'postalCode',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: QPayTokens.alert,
                      fontSize: 13,
                    ),
                  ),
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
