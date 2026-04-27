import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_choice_card.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/postcode_service.dart';

/// A-07 · Registered office + private email. Lives inside [OnboardingShell].
/// Two cards: QPay's London office (free, default) or your own address. When
/// "own" is picked, a postcode field appears — postcodes.io resolves it and
/// we display the derived Companies House jurisdiction.
enum _OfficeChoice { qpay, own }

class RegisteredOfficeScreen extends StatefulWidget {
  const RegisteredOfficeScreen({super.key});

  @override
  State<RegisteredOfficeScreen> createState() =>
      _RegisteredOfficeScreenState();
}

enum _PostcodeState { idle, checking, resolved, notFound, error }

class _RegisteredOfficeScreenState extends State<RegisteredOfficeScreen> {
  _OfficeChoice _choice = _OfficeChoice.qpay;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _postcodeCtrl = TextEditingController();
  final PostcodeService _postcodeService = PostcodeService();

  static const Duration _debounce = Duration(milliseconds: 350);
  Timer? _debounceTimer;
  int _reqSeq = 0;

  _PostcodeState _pcState = _PostcodeState.idle;
  PostcodeResult? _pcResult;
  String? _pcError;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _postcodeService.dispose();
    _emailCtrl.dispose();
    _postcodeCtrl.dispose();
    super.dispose();
  }

  bool _isEmailValid(String v) {
    final s = v.trim();
    if (s.isEmpty) return false;
    final at = s.indexOf('@');
    if (at <= 0 || at == s.length - 1) return false;
    final dot = s.indexOf('.', at);
    return dot > at + 1 && dot < s.length - 1;
  }

  void _onChoiceChanged(_OfficeChoice c) {
    setState(() {
      _choice = c;
      if (c == _OfficeChoice.qpay) {
        // Clear pending lookup state, but keep what user typed.
        _debounceTimer?.cancel();
        _pcState = _PostcodeState.idle;
        _pcResult = null;
        _pcError = null;
      } else {
        _schedulePostcodeLookup();
      }
    });
  }

  void _onPostcodeChanged() {
    final raw = _postcodeCtrl.text;
    setState(() {
      _pcState = _PostcodeState.idle;
      _pcResult = null;
      _pcError = null;
    });
    if (PostcodeService.isPlausible(raw)) {
      _schedulePostcodeLookup();
    } else {
      _debounceTimer?.cancel();
    }
  }

  void _schedulePostcodeLookup() {
    _debounceTimer?.cancel();
    if (!PostcodeService.isPlausible(_postcodeCtrl.text)) return;
    _debounceTimer = Timer(_debounce, _runPostcodeLookup);
  }

  Future<void> _runPostcodeLookup() async {
    final input = _postcodeCtrl.text.trim();
    if (!PostcodeService.isPlausible(input)) return;
    final seq = ++_reqSeq;
    setState(() {
      _pcState = _PostcodeState.checking;
      _pcError = null;
    });
    try {
      final res = await _postcodeService.lookup(input);
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _pcResult = res;
        _pcState = _PostcodeState.resolved;
      });
    } on PostcodeException catch (e) {
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _pcError = e.message;
        _pcState = e.message.contains('not found')
            ? _PostcodeState.notFound
            : _PostcodeState.error;
      });
    } catch (_) {
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _pcError = "Couldn't reach postcode lookup. Try again.";
        _pcState = _PostcodeState.error;
      });
    }
  }

  bool get _canContinue {
    final emailOk = _isEmailValid(_emailCtrl.text);
    if (!emailOk) return false;
    if (_choice == _OfficeChoice.qpay) return true;
    return _pcState == _PostcodeState.resolved && _pcResult != null;
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed:
              _canContinue ? () => context.push('/articles') : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Registered\noffice.',
            subtitle: 'Companies House mails legal post here. It\'s public.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, QPayTokens.s4),
            child: QChoiceCard(
              title: "QPay's London address",
              subtitle: 'Office 1.01, 411 Oxford St · included free',
              selected: _choice == _OfficeChoice.qpay,
              onTap: () => _onChoiceChanged(_OfficeChoice.qpay),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, QPayTokens.s4),
            child: QChoiceCard(
              title: 'My own address',
              subtitle:
                  "We'll set jurisdiction by postcode. Becomes public.",
              selected: _choice == _OfficeChoice.own,
              onTap: () => _onChoiceChanged(_OfficeChoice.own),
            ),
          ),
          if (_choice == _OfficeChoice.own)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, QPayTokens.s2, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QField(
                    label: 'POSTCODE',
                    controller: _postcodeCtrl,
                    placeholder: 'SW1A 1AA',
                    autofillHint: 'postalCode',
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9 ]'),
                      ),
                      LengthLimitingTextInputFormatter(8),
                      _UppercaseFormatter(),
                    ],
                    onChanged: (_) => _onPostcodeChanged(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 22,
                    child: _PostcodeStatus(
                      state: _pcState,
                      result: _pcResult,
                      errorMsg: _pcError,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, QPayTokens.s5, 24, 0),
            child: QField(
              label: 'PRIVATE EMAIL',
              controller: _emailCtrl,
              placeholder: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              autofillHint: 'email',
              onChanged: (_) => setState(() {}),
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
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _PostcodeStatus extends StatelessWidget {
  final _PostcodeState state;
  final PostcodeResult? result;
  final String? errorMsg;

  const _PostcodeStatus({
    required this.state,
    required this.result,
    required this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _PostcodeState.idle:
        return const SizedBox.shrink();
      case _PostcodeState.checking:
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
            const SizedBox(width: QPayTokens.s3),
            Text('Checking postcode…', style: QPayType.statusLine),
          ],
        );
      case _PostcodeState.resolved:
        final r = result!;
        return Row(
          children: [
            _dot(QPayTokens.success),
            const SizedBox(width: QPayTokens.s3),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: QPayType.statusLine,
                  children: [
                    TextSpan(
                      text: r.locality,
                      style: QPayType.statusLineStrong,
                    ),
                    TextSpan(text: ' · ${r.jurisdiction.label}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case _PostcodeState.notFound:
        return Row(
          children: [
            _dot(QPayTokens.alert),
            const SizedBox(width: QPayTokens.s3),
            Expanded(
              child: Text(
                errorMsg ?? 'Postcode not found.',
                style: QPayType.statusLine,
              ),
            ),
          ],
        );
      case _PostcodeState.error:
        return Row(
          children: [
            _dot(QPayTokens.warn),
            const SizedBox(width: QPayTokens.s3),
            Expanded(
              child: Text(
                errorMsg ?? 'Could not check postcode.',
                style: QPayType.statusLine,
              ),
            ),
          ],
        );
    }
  }

  Widget _dot(Color color) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
