import 'package:flutter/widgets.dart';

import 'auth_service.dart';

/// Makes the single [AuthService] instance available to descendant widgets
/// without pulling in a DI package.
class AuthProvider extends InheritedWidget {
  final AuthService service;

  const AuthProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static AuthService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(
      provider != null,
      'No AuthProvider found in widget tree. Wrap the app in AuthProvider.',
    );
    return provider!.service;
  }

  @override
  bool updateShouldNotify(AuthProvider oldWidget) =>
      oldWidget.service != service;
}
