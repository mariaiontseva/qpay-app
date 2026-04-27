import 'package:flutter/material.dart';

import '../tokens.dart';

/// Body-only scaffold used by screens that live inside a `ShellRoute`.
/// The enclosing shell already provides the top bar and safe area; this
/// widget paints the warm canvas background so the route transition has
/// something opaque to cross-fade under, and handles the scroll area +
/// optional pinned bottom bar.
class QInnerScreen extends StatelessWidget {
  final Widget child;
  final Widget? bottom;

  const QInnerScreen({
    super.key,
    required this.child,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: QPayTokens.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: child,
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
