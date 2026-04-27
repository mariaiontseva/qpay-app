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
import '../../../services/formation_state.dart';

/// A-10b · Co-directors + share split.
/// Lives inside [OnboardingShell]. Founder picks co-directors and the share
/// split — IN01 needs the allocation at filing time, so we don't defer it.
/// Each row has an inline % chip that opens a numeric edit sheet; the
/// footer shows live total + remaining/over-allocation, and Continue is
/// only enabled when the total equals exactly 100%.
class CoDirectorsScreen extends StatelessWidget {
  const CoDirectorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final cos = s.coDirectors;
    final total = s.totalSharePercent;
    final remaining = 100 - total;
    final canContinue = cos.isNotEmpty && s.sharesValid;
    final founderName = s.userName.trim().isEmpty ? 'You' : s.userName.trim();

    return QInnerScreen(
      bottom: QBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TotalRow(total: total, remaining: remaining),
            const SizedBox(height: QPayTokens.s4),
            QButton(
              label: cos.isEmpty
                  ? 'Add a co-director'
                  : (s.sharesValid
                      ? 'Send invites · Continue'
                      : 'Total must be 100%'),
              onPressed: canContinue ? () => context.push('/id-scan') : null,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Who else is\non board?',
            subtitle:
                "Each co-director gets an email invite to verify their own ID. We can't file IN01 until everyone's verified.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: _DirectorRow(
              title: founderName,
              subtitle: 'You',
              percent: s.sharePercents.isNotEmpty ? s.sharePercents[0] : 0,
              isFounder: true,
              onPercentTap: () => _editPercent(context, s, 0, founderName),
              onRemove: null,
            ),
          ),
          for (var i = 0; i < cos.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _DirectorRow(
                title: cos[i].name,
                subtitle: cos[i].email,
                percent: i + 1 < s.sharePercents.length
                    ? s.sharePercents[i + 1]
                    : 0,
                statusVerified: cos[i].status == 'verified',
                isFounder: false,
                onPercentTap: () =>
                    _editPercent(context, s, i + 1, cos[i].name),
                onRemove: () => s.removeCoDirector(cos[i].email),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: _AddRow(
              onTap: () async {
                final added = await _showAddDirectorSheet(context);
                if (added != null) s.addCoDirector(added);
              },
            ),
          ),
          if (cos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 14, 24, 0),
              child: Text(
                'Tap any % to edit. Adding or removing rebalances back to '
                'an equal split.',
                style: QPayType.heroSub,
              ),
            ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }

  Future<void> _editPercent(
    BuildContext context,
    FormationState s,
    int index,
    String name,
  ) async {
    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: QPayTokens.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _PercentSheet(
        name: name,
        initial: index < s.sharePercents.length ? s.sharePercents[index] : 0,
      ),
    );
    if (result != null) s.setSharePercent(index, result);
  }
}

class _TotalRow extends StatelessWidget {
  final int total;
  final int remaining;
  const _TotalRow({required this.total, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final ok = total == 100;
    final over = total > 100;
    final color = ok
        ? QPayTokens.success
        : (over ? QPayTokens.alert : QPayTokens.warn);
    final bg = ok
        ? QPayTokens.successBg
        : (over ? QPayTokens.alertBg : QPayTokens.warnBg);
    final detail = ok
        ? 'fully allocated'
        : over
            ? '${(-remaining)}% over — bring it back to 100'
            : '$remaining% remaining';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
      ),
      child: Row(
        children: [
          Icon(
            ok
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Total: $total%  ·  $detail',
              style: QPayType.optionTitle.copyWith(
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectorRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int percent;
  final bool isFounder;
  final bool statusVerified;
  final VoidCallback onPercentTap;
  final VoidCallback? onRemove;

  const _DirectorRow({
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.isFounder,
    this.statusVerified = false,
    required this.onPercentTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase.withValues(alpha: isFounder ? 1 : 0.7),
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(
          color: isFounder ? QPayTokens.ink : QPayTokens.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text(subtitle, style: QPayType.optionSub),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (!isFounder)
                      _StatusChip(
                        label: statusVerified
                            ? '✓ Verified'
                            : 'Pending invite',
                        success: statusVerified,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: QPayTokens.ink,
            borderRadius: BorderRadius.circular(QPayTokens.rPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(QPayTokens.rPill),
              onTap: onPercentTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Text(
                  '$percent%',
                  style: QPayType.optionTitle.copyWith(
                    color: const Color(0xFFFFFCF5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: QPayTokens.ink3,
                size: 20,
              ),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool success;
  const _StatusChip({required this.label, required this.success});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = success
        ? (QPayTokens.successBg, QPayTokens.success)
        : (QPayTokens.n100, QPayTokens.ink2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(QPayTokens.rPill),
      ),
      child: Text(
        label,
        style: QPayType.optionSub.copyWith(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  final VoidCallback onTap;
  const _AddRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(QPayTokens.rCard),
            border: Border.all(color: QPayTokens.borderStrong, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: QPayTokens.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFFFFFCF5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text('Add a co-director', style: QPayType.optionTitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentSheet extends StatefulWidget {
  final String name;
  final int initial;
  const _PercentSheet({required this.name, required this.initial});

  @override
  State<_PercentSheet> createState() => _PercentSheetState();
}

class _PercentSheetState extends State<_PercentSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial.toString());
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int? get _parsed {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n < 0 || n > 100) return null;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final ok = _parsed != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + inset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: QPayTokens.n300,
                  borderRadius: BorderRadius.circular(QPayTokens.rPill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${widget.name}\'s share',
                style: QPayType.heroTitle.copyWith(fontSize: 22),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'A whole number from 0 to 100.',
                style: QPayType.heroSub,
              ),
            ),
            const SizedBox(height: 14),
            QField(
              controller: _ctrl,
              placeholder: '50',
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: 16),
            QButton(
              label: 'Save',
              onPressed: ok
                  ? () => Navigator.of(context).pop(_parsed)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

Future<CoDirector?> _showAddDirectorSheet(BuildContext context) {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final emailRe = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');

  return showModalBottomSheet<CoDirector?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: QPayTokens.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          final inset = MediaQuery.of(ctx).viewInsets.bottom;
          final ok = nameCtrl.text.trim().length >= 2 &&
              emailRe.hasMatch(emailCtrl.text.trim());
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + inset),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: QPayTokens.n300,
                        borderRadius:
                            BorderRadius.circular(QPayTokens.rPill),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Invite a co-director',
                      style: QPayType.heroTitle.copyWith(fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 14),
                  QField(
                    controller: nameCtrl,
                    placeholder: 'First and last',
                    label: 'NAME',
                    autofocus: true,
                    onChanged: (_) => setSheet(() {}),
                  ),
                  const SizedBox(height: 12),
                  QField(
                    controller: emailCtrl,
                    placeholder: 'them@example.com',
                    label: 'EMAIL',
                    keyboardType: TextInputType.emailAddress,
                    autofillHint: 'email',
                    onChanged: (_) => setSheet(() {}),
                  ),
                  const SizedBox(height: 16),
                  QButton(
                    label: 'Add director',
                    onPressed: ok
                        ? () => Navigator.of(ctx).pop(
                              CoDirector(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                              ),
                            )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
