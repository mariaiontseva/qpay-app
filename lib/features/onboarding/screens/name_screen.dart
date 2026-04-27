import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/companies_house_provider.dart';
import '../../../services/companies_house_service.dart';
import '../../../services/formation_state.dart';

/// A-05 · Name your company. Lives inside [OnboardingShell].
/// Live availability check against the Companies House Public Data API,
/// debounced at 400 ms.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

enum _CheckState { idle, checking, available, taken, error }

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _ctrl = TextEditingController();

  static const Duration _debounce = Duration(milliseconds: 400);
  Timer? _debounceTimer;

  _CheckState _state = _CheckState.idle;
  NameAvailability? _result;
  String? _errorMsg;
  int _reqSeq = 0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stored = FormationProvider.read(context).companyName;
    if (stored.isNotEmpty && _ctrl.text.isEmpty) {
      _ctrl.text = stored;
      WidgetsBinding.instance.addPostFrameCallback((_) => _schedule());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _state = _CheckState.idle;
      _result = null;
      _errorMsg = null;
    });
    _schedule();
  }

  void _schedule() {
    _debounceTimer?.cancel();
    final trimmed = _ctrl.text.trim();
    if (trimmed.length < 3) return;
    _debounceTimer = Timer(_debounce, _run);
  }

  Future<void> _run() async {
    final name = _ctrl.text.trim();
    if (name.length < 3) return;
    final seq = ++_reqSeq;
    setState(() {
      _state = _CheckState.checking;
      _errorMsg = null;
    });
    try {
      final res = await CompaniesHouseProvider.of(context).checkAvailability(name);
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _result = res;
        _state = res.available ? _CheckState.available : _CheckState.taken;
      });
    } catch (e) {
      if (!mounted || seq != _reqSeq) return;
      setState(() {
        _state = _CheckState.error;
        _errorMsg = "Couldn't check right now. Retry in a moment.";
      });
    }
  }

  bool get _canContinue =>
      _state == _CheckState.available &&
      _ctrl.text.trim().length >= 3;

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Continue',
          onPressed: _canContinue
              ? () {
                  FormationProvider.read(context)
                      .setCompanyName(_ctrl.text.trim());
                  context.push('/sic');
                }
              : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Name your\ncompany.',
            subtitle: 'We\'ll add "Ltd" at the end.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              controller: _ctrl,
              placeholder: 'Your company',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: SizedBox(
              height: 24,
              child: _StatusLine(
                state: _state,
                result: _result,
                errorMsg: _errorMsg,
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final _CheckState state;
  final NameAvailability? result;
  final String? errorMsg;

  const _StatusLine({
    required this.state,
    required this.result,
    required this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _CheckState.idle:
        return const SizedBox.shrink();

      case _CheckState.checking:
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
            Text('Checking…', style: QPayType.statusLine),
          ],
        );

      case _CheckState.available:
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
                      text: result!.filedName,
                      style: QPayType.statusLineStrong,
                    ),
                    const TextSpan(text: ' is available'),
                  ],
                ),
              ),
            ),
          ],
        );

      case _CheckState.taken:
        return Row(
          children: [
            _dot(QPayTokens.alert),
            const SizedBox(width: QPayTokens.s3),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: QPayType.statusLine,
                  children: [
                    TextSpan(
                      text: result!.takenBy ?? result!.filedName,
                      style: QPayType.statusLineStrong,
                    ),
                    const TextSpan(text: ' is taken — try another name'),
                  ],
                ),
              ),
            ),
          ],
        );

      case _CheckState.error:
        return Row(
          children: [
            _dot(QPayTokens.warn),
            const SizedBox(width: QPayTokens.s3),
            Expanded(
              child: Text(
                errorMsg ?? 'Could not check',
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

