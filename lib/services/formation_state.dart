import 'package:flutter/material.dart';

import 'address_service.dart';
import 'sic_service.dart';

/// Shared mutable state for the company-formation flow.
/// Held at app root via [FormationProvider]; every screen that contributes
/// to the IN01 record reads from / writes to it. ChangeNotifier so the
/// summary screen can rebuild when anything changes.
class FormationState extends ChangeNotifier {
  // ───── Account holder (captured at signup) ─────
  String userName = '';
  String userEmail = '';

  // ───── Company basics ─────
  String companyName = '';
  /// Selected SIC codes; preserves insertion order.
  List<SicCode> sicCodes = const [];

  // ───── Registered office ─────
  /// True when the user picked QPay's London virtual office; false when
  /// they picked their own address. Defaults to QPay.
  bool useQPayOffice = true;
  UkAddress? ownAddress;

  // ───── Setters (notify on real changes) ─────
  void setUserName(String v) {
    if (userName == v) return;
    userName = v;
    notifyListeners();
  }

  void setUserEmail(String v) {
    if (userEmail == v) return;
    userEmail = v;
    notifyListeners();
  }

  void setCompanyName(String v) {
    if (companyName == v) return;
    companyName = v;
    notifyListeners();
  }

  void setSicCodes(List<SicCode> codes) {
    sicCodes = List.unmodifiable(codes);
    notifyListeners();
  }

  void useQPayOfficeChoice() {
    if (useQPayOffice && ownAddress == null) return;
    useQPayOffice = true;
    notifyListeners();
  }

  void setOwnAddress(UkAddress a) {
    useQPayOffice = false;
    ownAddress = a;
    notifyListeners();
  }

  // ───── Derived strings used by /summary ─────

  String get filedCompanyName {
    final n = companyName.trim();
    if (n.isEmpty) return '—';
    return n.toLowerCase().endsWith(' ltd') ? n : '$n Ltd';
  }

  String get sicSummary {
    if (sicCodes.isEmpty) return '—';
    final first = sicCodes.first;
    if (sicCodes.length == 1) return '${first.code} · ${first.description}';
    return '${first.code} · ${first.description} +${sicCodes.length - 1} more';
  }

  String get officeSummary {
    if (useQPayOffice) {
      return 'QPay London · 411 Oxford St';
    }
    final a = ownAddress;
    if (a == null) return '—';
    return '${a.line1} · ${a.locality} ${a.postcode}';
  }

  String get directorSummary {
    final n = userName.trim();
    if (n.isEmpty) return 'You · 100 shares · 100% PSC';
    return '$n · 100 shares · 100% PSC';
  }
}

/// InheritedNotifier so descendants get rebuilt when state changes.
class FormationProvider extends InheritedNotifier<FormationState> {
  const FormationProvider({
    super.key,
    required FormationState state,
    required super.child,
  }) : super(notifier: state);

  static FormationState of(BuildContext context) {
    final p = context
        .dependOnInheritedWidgetOfExactType<FormationProvider>();
    assert(p != null, 'FormationProvider missing above this widget');
    return p!.notifier!;
  }

  /// Read without subscribing to rebuilds.
  static FormationState read(BuildContext context) {
    final p =
        context.getInheritedWidgetOfExactType<FormationProvider>();
    assert(p != null, 'FormationProvider missing above this widget');
    return p!.notifier!;
  }
}
