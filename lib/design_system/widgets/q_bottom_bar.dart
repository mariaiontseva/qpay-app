import 'package:flutter/material.dart';

import '../tokens.dart';

/// Safe-area CTA wrapper used at the bottom of every flow screen.
class QBottomBar extends StatelessWidget {
  final Widget child;

  const QBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        QPayTokens.s5,
        QPayTokens.s4,
        QPayTokens.s5,
        QPayTokens.s6 - 2 + MediaQuery.of(context).padding.bottom,
      ),
      child: child,
    );
  }
}
