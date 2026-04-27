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

/// A-07A · Postcode entry.
/// Lives inside [OnboardingShell] as part of step 6 (registered office). The
/// "Find addresses" CTA fetches matches and pushes /address-results.
class PostcodeScreen extends StatefulWidget {
  const PostcodeScreen({super.key});

  @override
  State<PostcodeScreen> createState() => _PostcodeScreenState();
}

class _PostcodeScreenState extends State<PostcodeScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final AddressService _service = AddressService();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    _service.dispose();
    super.dispose();
  }

  bool get _looksValid => PostcodeService.isPlausible(_ctrl.text);

  Future<void> _onFind() async {
    if (!_looksValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final results = await _service.findAddresses(_ctrl.text.trim());
      if (!mounted) return;
      context.push(
        '/address-results',
        extra: {
          'postcode': _ctrl.text.trim().toUpperCase(),
          'addresses': results,
        },
      );
    } on PostcodeException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = "Couldn't reach lookup. Check connection and retry.",
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: _busy ? 'Searching…' : 'Find addresses',
          onPressed: _looksValid && !_busy ? _onFind : null,
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
              onChanged: (_) => setState(() {
                _error = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 0),
            child: SizedBox(
              height: 22,
              child: _StatusLine(
                valid: _looksValid,
                hasInput: _ctrl.text.trim().isNotEmpty,
                error: _error,
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
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

class _StatusLine extends StatelessWidget {
  final bool valid;
  final bool hasInput;
  final String? error;

  const _StatusLine({
    required this.valid,
    required this.hasInput,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Row(
        children: [
          _dot(QPayTokens.alert),
          const SizedBox(width: QPayTokens.s3),
          Expanded(
            child: Text(error!, style: QPayType.statusLine),
          ),
        ],
      );
    }
    if (!hasInput) return const SizedBox.shrink();
    if (valid) {
      return Row(
        children: [
          _dot(QPayTokens.success),
          const SizedBox(width: QPayTokens.s3),
          Text('Valid UK postcode', style: QPayType.statusLine),
        ],
      );
    }
    return Row(
      children: [
        _dot(QPayTokens.ink3),
        const SizedBox(width: QPayTokens.s3),
        Text('Keep typing…', style: QPayType.statusLine),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
