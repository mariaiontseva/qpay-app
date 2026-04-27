import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_address_sheet.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_edit_sheet.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_inner_screen.dart';
import '../../../design_system/widgets/q_pick_page.dart';
import '../../../services/countries.dart';
import '../../../services/formation_state.dart';

/// A-10 · Director details. Lives inside [OnboardingShell].
/// All fields editable; each row opens a field-appropriate editor:
///   • Full name      → text-input bottom sheet
///   • Date of birth  → date wheel picker (Cupertino style)
///   • Nationality    → searchable list of nationalities
///   • Country        → searchable list of countries
///   • Residential    → postcode lookup or manual address sheet
///   • Service        → routes back to /registered-office
///
/// Continue is disabled until every required field has a value.
class DirectorDetailsScreen extends StatelessWidget {
  const DirectorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    final fullName = s.userName.trim();
    final dob = s.directorDobLabel;
    final nationality = s.directorNationality;
    final country = s.directorCountryOfResidence;
    final residential = s.directorResidentialAddress;
    final serviceAddress = s.useQPayOffice
        ? 'QPay virtual office'
        : (s.ownAddress != null
            ? '${s.ownAddress!.line1}, ${s.ownAddress!.locality} ${s.ownAddress!.postcode}'
            : '—');

    final allFilled = fullName.isNotEmpty &&
        s.directorDob != null &&
        nationality.isNotEmpty &&
        country.isNotEmpty &&
        residential.isNotEmpty;

    return QInnerScreen(
      bottom: QBottomBar(
        child: QButton(
          label: 'Looks right',
          onPressed: allFilled
              ? () => context.push(s.isSolo ? '/id-scan' : '/co-directors')
              : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const QHeader(
            title: 'Your details.',
            subtitle:
                "You'll be the only director. Tap each field to fill it in.",
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Field(
                  label: 'Full name',
                  value: fullName,
                  placeholder: 'First and last',
                  onTap: () async {
                    final v = await showQEditSheet(
                      context,
                      title: 'Full name',
                      initial: fullName,
                      placeholder: 'First and last',
                    );
                    if (v != null && v.isNotEmpty) s.setUserName(v);
                  },
                ),
                _Field(
                  label: 'Date of birth',
                  value: dob,
                  placeholder: 'Tap to pick',
                  hint: 'Private',
                  onTap: () => _pickDob(context, s),
                ),
                _Field(
                  label: 'Nationality',
                  value: nationality,
                  placeholder: 'Tap to choose',
                  onTap: () async {
                    final c = await pushQPickPage<Country>(
                      context,
                      title: 'Nationality',
                      options: kCountries,
                      labelFor: (c) => c.nationality,
                      searchKeyFor: (c) => '${c.nationality} ${c.name}',
                      selected: kCountries.firstWhere(
                        (c) => c.nationality == nationality,
                        orElse: () => kCountries.first,
                      ),
                      searchPlaceholder: 'British, French, …',
                    );
                    if (c != null) s.setDirectorNationality(c.nationality);
                  },
                ),
                _Field(
                  label: 'Country of residence',
                  value: country,
                  placeholder: 'Tap to choose',
                  onTap: () async {
                    final c = await pushQPickPage<Country>(
                      context,
                      title: 'Country of residence',
                      options: kCountries,
                      labelFor: (c) => c.name,
                      searchKeyFor: (c) => '${c.name} ${c.nationality}',
                      selected: kCountries.firstWhere(
                        (c) => c.name == country,
                        orElse: () => kCountries.first,
                      ),
                      searchPlaceholder: 'United Kingdom, …',
                    );
                    if (c != null) s.setDirectorCountryOfResidence(c.name);
                  },
                ),
                _Field(
                  label: 'Residential address',
                  value: residential,
                  placeholder: 'Tap to add',
                  hint: 'Private',
                  onTap: () async {
                    final v = await showQAddressSheet(
                      context,
                      title: 'Residential address',
                      initial: residential,
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

  void _pickDob(BuildContext context, FormationState s) {
    final initial = s.directorDob ?? DateTime(1995, 1, 1);
    DateTime tmp = initial;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: QPayTokens.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: QPayTokens.n300,
                borderRadius: BorderRadius.circular(QPayTokens.rPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Date of birth',
                  style: QPayType.heroTitle.copyWith(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Companies House requires director to be 16 or over.',
                  style: QPayType.heroSub,
                ),
              ),
            ),
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: DateTime(1900, 1, 1),
                maximumDate: DateTime.now().subtract(
                  const Duration(days: 16 * 365),
                ),
                onDateTimeChanged: (d) => tmp = d,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: QButton(
                label: 'Save',
                onPressed: () {
                  s.setDirectorDob(tmp);
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final String? placeholder;
  final String? hint;
  final VoidCallback onTap;
  const _Field({
    required this.label,
    required this.value,
    this.placeholder,
    this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty;
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
              border: Border.all(
                color: isEmpty ? QPayTokens.border : QPayTokens.borderStrong,
                width: 1.5,
              ),
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
                      Text(
                        isEmpty ? (placeholder ?? '—') : value,
                        style: QPayType.optionTitle.copyWith(
                          color: isEmpty ? QPayTokens.ink4 : QPayTokens.ink,
                          fontWeight:
                              isEmpty ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isEmpty ? Icons.add_rounded : Icons.chevron_right_rounded,
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
