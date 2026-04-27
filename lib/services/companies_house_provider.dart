import 'package:flutter/widgets.dart';

import 'companies_house_service.dart';

/// Exposes the [CompaniesHouseService] to descendant widgets without
/// dragging in a DI library.
class CompaniesHouseProvider extends InheritedWidget {
  final CompaniesHouseService service;

  const CompaniesHouseProvider({
    super.key,
    required this.service,
    required super.child,
  });

  static CompaniesHouseService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<CompaniesHouseProvider>();
    assert(
      provider != null,
      'No CompaniesHouseProvider found in widget tree.',
    );
    return provider!.service;
  }

  @override
  bool updateShouldNotify(CompaniesHouseProvider oldWidget) =>
      oldWidget.service != service;
}
