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
import '../../../design_system/widgets/q_screen.dart';
import '../../../services/companies_house_provider.dart';
import '../../../services/companies_house_service.dart';
import '../../../services/formation_state.dart';

/// Existing-Ltd company lookup, preview, and confirm — all on one screen.
/// Replaces the old two-step (B-01 lookup + B-02 confirm) sequence.
/// User types eight digits, the CH record renders below in a single
/// review card, and "Yes, it's me" advances straight to /director-details.
class ExistingLookupScreen extends StatefulWidget {
  const ExistingLookupScreen({super.key});

  @override
  State<ExistingLookupScreen> createState() => _ExistingLookupScreenState();
}

enum _LookupState { idle, checking, found, blocked, notFound, error }

class _ExistingLookupScreenState extends State<ExistingLookupScreen> {
  static const Duration _debounce = Duration(milliseconds: 250);

  final _ctrl = TextEditingController();
  Timer? _debounceTimer;
  int _seq = 0;

  _LookupState _state = _LookupState.idle;
  CompanyDetails? _details;
  String? _err;
  /// Number for which we already auto-dismissed the keyboard. We don't
  /// dismiss again when the user edits and lands back on the same number,
  /// otherwise mid-edit dismisses make further typing painful.
  String? _dismissedFor;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounceTimer?.cancel();
    setState(() {
      _state = _LookupState.idle;
      _details = null;
      _err = null;
    });
    if (_ctrl.text.trim().length == 8) {
      _debounceTimer = Timer(_debounce, _runLookup);
    }
  }

  Future<void> _runLookup() async {
    final number = _ctrl.text.trim();
    if (number.length != 8) return;
    final s = ++_seq;
    setState(() => _state = _LookupState.checking);
    try {
      final d =
          await CompaniesHouseProvider.of(context).lookupByNumber(number);
      if (!mounted || s != _seq) return;
      _details = d;
      final blocked = d.status == 'dissolved' ||
          d.status == 'liquidation' ||
          d.status == 'removed';
      setState(() => _state =
          blocked ? _LookupState.blocked : _LookupState.found);
      // Dismiss keyboard the first time we find a given number, so the
      // user can see the full card. Re-edits that land back on the same
      // number do NOT re-dismiss — keeps mid-edit typing usable.
      if (!blocked && number != _dismissedFor) {
        FocusManager.instance.primaryFocus?.unfocus();
        _dismissedFor = number;
      }
    } on CompanyNotFoundException {
      if (!mounted || s != _seq) return;
      setState(() => _state = _LookupState.notFound);
    } catch (_) {
      if (!mounted || s != _seq) return;
      setState(() {
        _state = _LookupState.error;
        _err = "Couldn't reach Companies House. Try again.";
      });
    }
  }

  void _onContinue() {
    final d = _details;
    if (d == null || _state != _LookupState.found) return;
    FormationProvider.read(context).setExistingLtd(
      number: d.number,
      name: d.name,
      incorporated: d.incorporatedLabel,
      status: d.status,
      jurisdiction: d.jurisdictionLabel,
      registeredOffice: d.registeredOffice,
      sicCodes: d.sicCodes,
    );
    context.go('/director-details');
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _state == _LookupState.found && _details != null;
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: "Yes, it's me",
          onPressed: canContinue ? _onContinue : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackBar(),
          const QHeader(
            title: "What's the\ncompany number?",
            subtitle:
                "Eight digits from your incorporation certificate. We'll look it up at Companies House.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: QField(
              controller: _ctrl,
              placeholder: '15837421',
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _PreviewArea(
              state: _state,
              details: _details,
              err: _err,
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(QPayTokens.s5, 10, QPayTokens.s6, 0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(QPayTokens.rMd),
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: QPayTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final _LookupState state;
  final CompanyDetails? details;
  final String? err;

  const _PreviewArea({required this.state, this.details, this.err});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _LookupState.idle:
        return const SizedBox.shrink();
      case _LookupState.checking:
        return const _StatusLine(
          color: QPayTokens.ink3,
          spinner: true,
          text: 'Looking up…',
        );
      case _LookupState.found:
      case _LookupState.blocked:
        return _PreviewCard(
          details: details!,
          blocked: state == _LookupState.blocked,
        );
      case _LookupState.notFound:
        return const _StatusLine(
          color: QPayTokens.alert,
          text: 'No company with that number on the register.',
        );
      case _LookupState.error:
        return _StatusLine(
          color: QPayTokens.warn,
          text: err ?? 'Lookup failed.',
        );
    }
  }
}

class _StatusLine extends StatelessWidget {
  final Color color;
  final String text;
  final bool spinner;
  const _StatusLine({
    required this.color,
    required this.text,
    this.spinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (spinner)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: QPayTokens.ink3,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: QPayType.statusLine),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final CompanyDetails details;
  final bool blocked;

  const _PreviewCard({required this.details, required this.blocked});

  @override
  Widget build(BuildContext context) {
    final statusColor = blocked ? QPayTokens.alert : QPayTokens.success;
    final statusBg = blocked ? QPayTokens.alertBg : QPayTokens.successBg;

    final stats = <_Stat>[
      if (details.incorporatedLabel.isNotEmpty)
        _Stat(label: 'Incorporated', value: details.incorporatedLabel),
      if (details.jurisdictionLabel.isNotEmpty)
        _Stat(label: 'Jurisdiction', value: details.jurisdictionLabel),
      if (details.registeredOffice.isNotEmpty)
        _Stat(label: 'Registered office', value: details.registeredOffice),
      if (details.sicCodes.isNotEmpty)
        _Stat(
          label: 'SIC code${details.sicCodes.length == 1 ? '' : 's'}',
          value: details.sicCodes.join(', '),
          mono: true,
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard + 4),
        border: Border.all(color: QPayTokens.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── Status pill + number ─────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(QPayTokens.rPill),
                ),
                child: Text(
                  _statusLabel(details.status),
                  style: QPayType.fieldLabel.copyWith(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                details.number,
                style: QPayType.progressNum.copyWith(
                  color: QPayTokens.ink3,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(details.name, style: QPayType.heroTitle.copyWith(fontSize: 22)),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: QPayTokens.border),
            const SizedBox(height: 12),
            for (var i = 0; i < stats.length; i++) ...[
              stats[i],
              if (i != stats.length - 1) const SizedBox(height: 12),
            ],
          ],
          if (blocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: QPayTokens.alertBg,
                borderRadius: BorderRadius.circular(QPayTokens.rCard),
              ),
              child: Text(
                'This company is ${details.status}. Pick another or form a new one.',
                style: QPayType.heroSub.copyWith(color: QPayTokens.alert),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1);
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _Stat({
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: QPayType.fieldLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: (mono ? QPayType.progressNum : QPayType.optionTitle)
                .copyWith(
              color: QPayTokens.ink,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
