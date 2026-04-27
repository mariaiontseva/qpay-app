import 'dart:async';

import 'package:flutter/material.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/backend_provider.dart';
import '../../../services/backend_service.dart';
import '../../../services/companies_house_provider.dart';
import '../../../services/companies_house_service.dart';

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
  final TextEditingController _ctrl =
      TextEditingController(text: 'Orca Design');

  static const Duration _debounce = Duration(milliseconds: 400);
  Timer? _debounceTimer;

  _CheckState _state = _CheckState.idle;
  NameAvailability? _result;
  String? _errorMsg;
  int _reqSeq = 0;

  // Submission to the backend (which round-trips to CH XML Gateway, or
  // falls back to mock-accepted while creds are under review).
  bool _submitting = false;
  FormationSubmitResult? _submitResult;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);
    // Kick off an initial check for the prefilled sample name.
    WidgetsBinding.instance.addPostFrameCallback((_) => _schedule());
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
      _ctrl.text.trim().length >= 3 &&
      !_submitting;

  Future<void> _submit() async {
    if (!_canContinue) return;
    final backend = BackendProvider.of(context);
    if (!backend.isConfigured) {
      setState(() => _submitError =
          'Backend URL not configured. Build with --dart-define=BACKEND_URL=...');
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
      _submitResult = null;
    });
    try {
      final res = await backend.submitSample(_ctrl.text.trim());
      if (!mounted) return;
      setState(() => _submitResult = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitError = 'Backend error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: _submitting ? 'Filing…' : 'File with Companies House',
          onPressed: _canContinue ? _submit : null,
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
          if (_submitResult != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: _SubmitResultCard(result: _submitResult!),
            ),
          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Text(
                _submitError!,
                style: QPayType.heroSub.copyWith(
                  color: QPayTokens.alert,
                  fontSize: 13,
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

class _SubmitResultCard extends StatelessWidget {
  final FormationSubmitResult result;
  const _SubmitResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final accepted = result.outcome == 'accepted' ||
        result.outcome == 'acknowledged';
    final tint =
        accepted ? QPayTokens.success : QPayTokens.alert;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: tint, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                accepted ? 'Filed' : 'Rejected',
                style: QPayType.optionTitle.copyWith(color: tint),
              ),
              const Spacer(),
              Text(result.transactionId, style: QPayType.footerNote),
            ],
          ),
          const SizedBox(height: 10),
          if (result.filedName != null)
            Text(
              result.filedName!,
              style: QPayType.optionTitle,
            ),
          const SizedBox(height: 4),
          Text('Outcome: ${result.outcome}', style: QPayType.optionSub),
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 6),
            for (final e in result.errors)
              Text(
                '· ${e.code ?? ''} ${e.text}',
                style: QPayType.optionSub.copyWith(color: QPayTokens.alert),
              ),
          ],
        ],
      ),
    );
  }
}
