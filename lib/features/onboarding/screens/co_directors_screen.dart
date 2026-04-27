import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_field.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/formation_state.dart';

/// A-10b · Co-directors. Lives inside [OnboardingShell].
/// Founder lists their co-directors (name + email). On Continue we send
/// each one a deep-link invite to install QPay, do their own signup, and
/// run their own ID verification — ECCTA requires every director to
/// verify themselves. The IN01 is held until everyone is verified.
class CoDirectorsScreen extends StatelessWidget {
  const CoDirectorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final cos = s.coDirectors;
    final allDirectors = 1 + cos.length;
    final pct = s.equalSharePercent;
    final canContinue = cos.isNotEmpty;

    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: canContinue ? 'Send invites · Continue' : 'Add a co-director',
          onPressed: canContinue ? () => context.push('/id-scan') : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Who else is\non board?',
            subtitle:
                "Each co-director will get an email invite to verify their own ID. We can't file IN01 until everyone's verified.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: _FounderRow(name: s.userName, percent: pct),
          ),
          for (final d in cos)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _CoRow(
                director: d,
                percent: pct,
                onRemove: () => s.removeCoDirector(d.email),
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
              padding: const EdgeInsets.fromLTRB(28, 18, 24, 0),
              child: Text(
                'Default split: $allDirectors × $pct% — equal shares. '
                'Customise later from the company dashboard.',
                style: QPayType.heroSub,
              ),
            ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _FounderRow extends StatelessWidget {
  final String name;
  final int percent;
  const _FounderRow({required this.name, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.ink, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'You' : name,
                  style: QPayType.optionTitle,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(label: 'You', tone: _ChipTone.dark),
                    const SizedBox(width: 6),
                    _Chip(label: '$percent%', tone: _ChipTone.muted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoRow extends StatelessWidget {
  final CoDirector director;
  final int percent;
  final VoidCallback onRemove;
  const _CoRow({
    required this.director,
    required this.percent,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(director.name, style: QPayType.optionTitle),
                const SizedBox(height: 2),
                Text(director.email, style: QPayType.optionSub),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Chip(
                      label: director.status == 'verified'
                          ? '✓ Verified'
                          : 'Pending invite',
                      tone: director.status == 'verified'
                          ? _ChipTone.success
                          : _ChipTone.muted,
                    ),
                    const SizedBox(width: 6),
                    _Chip(label: '$percent%', tone: _ChipTone.muted),
                  ],
                ),
              ],
            ),
          ),
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
            border: Border.all(
              color: QPayTokens.borderStrong,
              width: 1.5,
              style: BorderStyle.solid,
            ),
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

enum _ChipTone { dark, muted, success }

class _Chip extends StatelessWidget {
  final String label;
  final _ChipTone tone;
  const _Chip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _ChipTone.dark => (QPayTokens.ink, const Color(0xFFFFFCF5)),
      _ChipTone.muted => (QPayTokens.n100, QPayTokens.ink2),
      _ChipTone.success => (QPayTokens.successBg, QPayTokens.success),
    };
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
