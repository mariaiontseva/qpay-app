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

/// B-01 · Existing-Ltd company-number lookup.
/// Hits the Companies House public-data API directly via
/// CompaniesHouseService.lookupByNumber, persists the real record
/// (name, status, incorporation, office, SICs) into FormationState.
class ExistingLookupScreen extends StatefulWidget {
  const ExistingLookupScreen({super.key});

  @override
  State<ExistingLookupScreen> createState() => _ExistingLookupScreenState();
}

enum _LookupState { idle, checking, found, dissolved, notFound, error }

class _ExistingLookupScreenState extends State<ExistingLookupScreen> {
  final _ctrl = TextEditingController();
  _LookupState _state = _LookupState.idle;
  CompanyDetails? _details;
  String? _err;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final number = _ctrl.text.trim();
    if (number.length != 8) return;
    setState(() {
      _state = _LookupState.checking;
      _err = null;
      _details = null;
    });
    try {
      final d =
          await CompaniesHouseProvider.of(context).lookupByNumber(number);
      if (!mounted) return;
      if (d.status == 'dissolved' ||
          d.status == 'liquidation' ||
          d.status == 'removed') {
        setState(() {
          _details = d;
          _state = _LookupState.dissolved;
        });
        return;
      }
      _details = d;
      setState(() => _state = _LookupState.found);
      FormationProvider.read(context).setExistingLtd(
        number: d.number,
        name: d.name,
        incorporated: d.incorporatedLabel,
        status: d.status,
        jurisdiction: d.jurisdictionLabel,
        registeredOffice: d.registeredOffice,
        sicCodes: d.sicCodes,
      );
      if (!mounted) return;
      context.push('/existing-confirm');
    } on CompanyNotFoundException {
      if (!mounted) return;
      setState(() => _state = _LookupState.notFound);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _LookupState.error;
        _err = "Couldn't reach Companies House. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _ctrl.text.trim().length == 8 &&
        _state != _LookupState.checking;
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: _state == _LookupState.checking ? 'Looking up…' : 'Continue',
          onPressed: canContinue ? _onContinue : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              onChanged: (_) => setState(() {
                _state = _LookupState.idle;
                _err = null;
                _details = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 0),
            child: SizedBox(
              height: 22,
              child: _Status(
                state: _state,
                details: _details,
                err: _err,
              ),
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final _LookupState state;
  final CompanyDetails? details;
  final String? err;
  const _Status({required this.state, this.details, this.err});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _LookupState.idle:
        return const SizedBox.shrink();
      case _LookupState.checking:
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
            Text('Checking…', style: QPayType.statusLine),
          ],
        );
      case _LookupState.found:
        return Row(
          children: [
            _dot(QPayTokens.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: QPayType.statusLine,
                  children: [
                    const TextSpan(text: 'Active · '),
                    TextSpan(
                      text: details?.name ?? 'company found',
                      style: QPayType.statusLineStrong,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case _LookupState.dissolved:
        return Row(
          children: [
            _dot(QPayTokens.alert),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${details?.name ?? "This company"} is ${details?.status}.',
                style: QPayType.statusLine,
              ),
            ),
          ],
        );
      case _LookupState.notFound:
        return Row(
          children: [
            _dot(QPayTokens.alert),
            const SizedBox(width: 10),
            Expanded(
              child: Text('No company with that number.',
                  style: QPayType.statusLine),
            ),
          ],
        );
      case _LookupState.error:
        return Row(
          children: [
            _dot(QPayTokens.warn),
            const SizedBox(width: 10),
            Expanded(
              child: Text(err ?? 'Lookup failed.', style: QPayType.statusLine),
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
