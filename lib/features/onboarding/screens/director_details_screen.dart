import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_edit_sheet.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../services/formation_state.dart';

/// A-10 · Director details. Lives inside [OnboardingShell].
/// Every row is editable — taps open a single-field bottom sheet that
/// writes back into [FormationState] on Save. Service address is derived
/// from the registered office choice and edited via that screen.
class DirectorDetailsScreen extends StatelessWidget {
  const DirectorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final fullName = s.userName.trim().isEmpty ? '—' : s.userName.trim();
    final serviceAddress = s.useQPayOffice
        ? 'QPay virtual office'
        : (s.ownAddress != null
            ? '${s.ownAddress!.line1}, ${s.ownAddress!.locality} ${s.ownAddress!.postcode}'
            : '—');

    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Looks right',
          onPressed: () => context.push('/id-scan'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Your details.',
            subtitle: "You'll be the only director. Tap any field to edit.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Field(
                  label: 'Full name',
                  value: fullName,
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Full name',
                      initial: s.userName,
                      placeholder: 'First and last',
                    );
                    if (v != null && v.isNotEmpty) s.setUserName(v);
                  },
                ),
                _Field(
                  label: 'Date of birth',
                  value: s.directorDob,
                  hint: 'Private',
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Date of birth',
                      initial: s.directorDob,
                      placeholder: 'DD MMM YYYY',
                    );
                    if (v != null && v.isNotEmpty) s.setDirectorDob(v);
                  },
                ),
                _Field(
                  label: 'Nationality',
                  value: s.directorNationality,
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Nationality',
                      initial: s.directorNationality,
                      placeholder: 'British',
                    );
                    if (v != null && v.isNotEmpty) {
                      s.setDirectorNationality(v);
                    }
                  },
                ),
                _Field(
                  label: 'Country of residence',
                  value: s.directorCountryOfResidence,
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Country of residence',
                      initial: s.directorCountryOfResidence,
                      placeholder: 'United Kingdom',
                    );
                    if (v != null && v.isNotEmpty) {
                      s.setDirectorCountryOfResidence(v);
                    }
                  },
                ),
                _Field(
                  label: 'Residential address',
                  value: s.directorResidentialAddress,
                  hint: 'Private',
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Residential address',
                      initial: s.directorResidentialAddress,
                      placeholder: '45 King\'s Rd, London SW3 4UH',
                      multiline: true,
                    );
                    if (v != null && v.isNotEmpty) {
                      s.setDirectorResidentialAddress(v);
                    }
                  },
                ),
                _Field(
                  label: 'Service address',
                  value: serviceAddress,
                  hint: 'Public',
                  onTap: () => context.go('/registered-office'),
                ),
              ],
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final VoidCallback onTap;
  const _Field({
    required this.label,
    required this.value,
    this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QPayTokens.s3),
      child: Material(
        color: QPayTokens.cardBase.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(QPayTokens.rCard),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
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
                      Row(
                        children: [
                          Text(label, style: QPayType.fieldLabel),
                          if (hint != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: QPayTokens.n100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hint!,
                                style: QPayType.fieldLabel.copyWith(
                                  fontSize: 9.5,
                                  color: QPayTokens.ink2,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(value, style: QPayType.optionTitle),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: QPayTokens.ink3,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
