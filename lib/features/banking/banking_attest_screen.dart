import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/tokens.dart';
import '../../design_system/typography.dart';
import '../../design_system/widgets/q_bottom_bar.dart';
import '../../design_system/widgets/q_button.dart';
import '../../design_system/widgets/q_field.dart';
import '../../design_system/widgets/q_header.dart';
import '../../services/formation_state.dart';

/// B-06 · Sanctions cleared + PEP self-declaration + optional UTR/VAT.
/// Final attestation before the QPay account opens.
class BankingAttestScreen extends StatefulWidget {
  const BankingAttestScreen({super.key});

  @override
  State<BankingAttestScreen> createState() => _BankingAttestScreenState();
}

class _BankingAttestScreenState extends State<BankingAttestScreen> {
  late final TextEditingController _utr;
  late final TextEditingController _vat;

  @override
  void initState() {
    super.initState();
    final s = FormationProviderRead(context);
    _utr = TextEditingController(text: s?.utr ?? '');
    _vat = TextEditingController(text: s?.vatNumber ?? '');
  }

  static FormationState? FormationProviderRead(BuildContext c) {
    try {
      return FormationProvider.read(c);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _utr.dispose();
    _vat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = FormationProvider.of(context);
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackBar(),
            const QHeader(
              title: 'Last attestation.',
              subtitle:
                  "We've already screened you against UK and OFAC sanctions lists. Two last self-declarations.",
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: QPayTokens.successBg,
                      borderRadius: BorderRadius.circular(QPayTokens.rPill),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: QPayTokens.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sanctions screening · cleared',
                            style: QPayType.optionTitle.copyWith(
                              fontSize: 13,
                              color: QPayTokens.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PepToggle(
                    isPep: s.isPep,
                    onChanged: (v) => s.setIsPep(v),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "A PEP isn't a blocker — we just apply enhanced due "
                    'diligence. UTR + VAT are optional now.',
                    style: QPayType.heroSub,
                  ),
                  const SizedBox(height: 18),
                  QField(
                    controller: _utr,
                    label: 'UTR (HMRC) — OPTIONAL',
                    placeholder: '1234567890',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: s.setUtr,
                  ),
                  const SizedBox(height: 12),
                  QField(
                    controller: _vat,
                    label: 'VAT NUMBER — OPTIONAL',
                    placeholder: 'GB123456789',
                    onChanged: s.setVatNumber,
                  ),
                ],
              ),
            ),
            QBottomBar(
              child: QButton(
                label: 'Confirm + open account',
                onPressed: () => context.push('/banking-open'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PepToggle extends StatelessWidget {
  final bool isPep;
  final ValueChanged<bool> onChanged;
  const _PepToggle({required this.isPep, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: QPayTokens.cardBase,
        borderRadius: BorderRadius.circular(QPayTokens.rCard),
        border: Border.all(color: QPayTokens.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PEP self-declaration', style: QPayType.fieldLabel),
                const SizedBox(height: 4),
                Text(
                  'Are you a Politically Exposed Person?',
                  style: QPayType.optionTitle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          _Switch(value: isPep, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Switch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? QPayTokens.ink : QPayTokens.n200,
          borderRadius: BorderRadius.circular(QPayTokens.rPill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 140),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF5),
              shape: BoxShape.circle,
            ),
          ),
        ),
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
