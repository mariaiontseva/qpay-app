import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Two-line hero title with optional subtitle — the standard screen header
/// across S01 through S05.
class QHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double topPadding;

  const QHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.topPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        QPayTokens.s6,
        topPadding,
        QPayTokens.s6,
        QPayTokens.s2 + 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: QPayType.heroTitle),
          if (subtitle != null) ...[
            const SizedBox(height: QPayTokens.s3),
            Text(subtitle!, style: QPayType.heroSub),
          ],
        ],
      ),
    );
  }
}
