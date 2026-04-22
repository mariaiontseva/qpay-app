import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens.dart';
import '../../../design_system/typography.dart';
import '../../../design_system/widgets/q_bottom_bar.dart';
import '../../../design_system/widgets/q_button.dart';
import '../../../design_system/widgets/q_header.dart';
import '../../../design_system/widgets/q_numbered_row.dart';
import '../../../design_system/widgets/q_progress_bar.dart';
import '../../../design_system/widgets/q_screen.dart';

/// A-03 · Pre-flight checklist.
/// Three numbered items: passport, home address, company idea.
class PreflightScreen extends StatelessWidget {
  const PreflightScreen({super.key});

  static const _items = <(String, String)>[
    ('Passport or UK licence', 'For ID verification with GOV.UK'),
    ('Home address', 'Kept private — never public'),
    ('Your company idea', 'A name and what it does'),
  ];

  @override
  Widget build(BuildContext context) {
    return QScreen(
      bottom: QBottomBar(
        child: QButton(
          label: "Start — it's free",
          onPressed: () => context.push('/solo'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QProgressBar(step: 2, total: 9, onBack: () => context.pop()),
          const QHeader(
            title: 'Before we start —\ngrab these three things.',
            subtitle:
                'We pay the £100 Companies House fee. You keep the company.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                for (var i = 0; i < _items.length; i++)
                  QNumberedRow(
                    number: i + 1,
                    title: _items[i].$1,
                    sub: _items[i].$2,
                    isFirst: i == 0,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Text(
              'Your Ltd number arrives in 24 hours. Your account opens the same day.',
              style: QPayType.footerNote,
            ),
          ),
          const SizedBox(height: QPayTokens.s6),
        ],
      ),
    );
  }
}
