import 'package:flutter/widgets.dart';

import 'backend_service.dart';

class BackendProvider extends InheritedWidget {
  final BackendService service;

  const BackendProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static BackendService of(BuildContext context) {
    final p = context.dependOnInheritedWidgetOfExactType<BackendProvider>();
    assert(p != null, 'No BackendProvider in context.');
    return p!.service;
  }

  @override
  bool updateShouldNotify(BackendProvider oldWidget) =>
      oldWidget.service != service;
}
