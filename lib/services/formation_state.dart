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

  // ───── Team (A-04 + /co-directors) ─────
  /// True when the founder is incorporating alone. Set on /solo.
  bool isSolo = true;
  /// Invited co-directors. Each will receive an email with a deep link
  /// into QPay where they do their own signup + ID verification before
  /// the IN01 can be filed.
  List<CoDirector> coDirectors = const [];

  /// Share split, founder first, then co-directors in order.
  /// Length always equals 1 + coDirectors.length. Auto-balanced to an
  /// equal split whenever co-directors are added or removed. The user
  /// can override individual rows on /co-directors; we still require
  /// the total to equal 100% before letting them continue.
  List<int> sharePercents = const [100];

  // ───── Director (editable on /director-details) ─────
  /// All fields start empty — the only auto-filled identity data is the
  /// `userName` captured at signup. Everything else needs the user to enter
  /// it themselves (with field-appropriate UX in director_details_screen).
  DateTime? directorDob;
  String directorNationality = '';
  String directorCountryOfResidence = '';
  String directorResidentialAddress = '';

  // ───── ID verification capture ─────
  /// File path of the document photo captured on /id-scan.
  String? documentPhotoPath;
  /// File path of the selfie captured on /id-selfie.
  String? selfiePhotoPath;

  // ───── Path B (existing-Ltd onboarding) ─────
  /// True when the user is onboarding an existing Ltd, not forming one.
  bool isExistingLtd = false;
  String existingCompanyNumber = '';
  String existingIncorporationDate = '';
  String existingStatus = '';
  String existingJurisdiction = '';
  String existingRegisteredOffice = '';
  List<String> existingSicCodes = const [];
  /// Source of funds for the AML question on /existing-aml.
  String sourceOfFunds = '';
  /// Expected monthly volume bucket on /existing-aml.
  String expectedVolume = '';
  /// PEP self-declaration. False = "No", true = "Yes" (triggers EDD).
  bool isPep = false;
  String utr = '';
  String vatNumber = '';

  /// Whether the QPay business account has been opened. True for Path A
  /// (set by /live) and after the existing-Ltd banking sub-flow finishes.
  bool bankAccountOpen = false;
  /// External bank linked via Open Banking.
  bool externalBankLinked = false;

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

  void setIsSolo(bool v) {
    if (isSolo == v) return;
    isSolo = v;
    if (v) coDirectors = const [];
    _resetEqualSplit();
    notifyListeners();
  }

  void addCoDirector(CoDirector d) {
    coDirectors = List.unmodifiable([...coDirectors, d]);
    _resetEqualSplit();
    notifyListeners();
  }

  void removeCoDirector(String email) {
    coDirectors = List.unmodifiable(
      coDirectors.where((d) => d.email != email),
    );
    _resetEqualSplit();
    notifyListeners();
  }

  void setSharePercent(int index, int pct) {
    if (index < 0 || index >= sharePercents.length) return;
    final clamped = pct.clamp(0, 100);
    if (sharePercents[index] == clamped) return;
    final next = [...sharePercents];
    next[index] = clamped;
    sharePercents = List.unmodifiable(next);
    notifyListeners();
  }

  /// Recompute an equal split across founder + every co-director.
  /// Any rounding leftover lands on the founder so the total stays at 100%.
  void _resetEqualSplit() {
    final n = 1 + coDirectors.length;
    final base = 100 ~/ n;
    final remainder = 100 - base * n;
    sharePercents = List.unmodifiable(
      [base + remainder, ...List.filled(n - 1, base)],
    );
  }

  int get totalSharePercent => sharePercents.fold<int>(0, (a, b) => a + b);
  bool get sharesValid => totalSharePercent == 100;

  void setDirectorDob(DateTime? v) {
    if (directorDob == v) return;
    directorDob = v;
    notifyListeners();
  }

  /// Format DOB for display per UK convention (e.g. "12 May 1988").
  String get directorDobLabel {
    final d = directorDob;
    if (d == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void setDirectorNationality(String v) {
    if (directorNationality == v) return;
    directorNationality = v;
    notifyListeners();
  }

  void setDirectorCountryOfResidence(String v) {
    if (directorCountryOfResidence == v) return;
    directorCountryOfResidence = v;
    notifyListeners();
  }

  void setDirectorResidentialAddress(String v) {
    if (directorResidentialAddress == v) return;
    directorResidentialAddress = v;
    notifyListeners();
  }

  void setDocumentPhoto(String path) {
    documentPhotoPath = path;
    notifyListeners();
  }

  void setSelfiePhoto(String path) {
    selfiePhotoPath = path;
    notifyListeners();
  }

  void setExistingLtd({
    required String number,
    required String name,
    required String incorporated,
    String status = '',
    String jurisdiction = '',
    String registeredOffice = '',
    List<String> sicCodes = const [],
  }) {
    isExistingLtd = true;
    existingCompanyNumber = number;
    companyName = name;
    existingIncorporationDate = incorporated;
    existingStatus = status;
    existingJurisdiction = jurisdiction;
    existingRegisteredOffice = registeredOffice;
    existingSicCodes = List.unmodifiable(sicCodes);
    notifyListeners();
  }

  void setSourceOfFunds(String v) {
    if (sourceOfFunds == v) return;
    sourceOfFunds = v;
    notifyListeners();
  }

  void setExpectedVolume(String v) {
    if (expectedVolume == v) return;
    expectedVolume = v;
    notifyListeners();
  }

  void setIsPep(bool v) {
    if (isPep == v) return;
    isPep = v;
    notifyListeners();
  }

  void setUtr(String v) {
    if (utr == v) return;
    utr = v;
    notifyListeners();
  }

  void setVatNumber(String v) {
    if (vatNumber == v) return;
    vatNumber = v;
    notifyListeners();
  }

  void setBankAccountOpen(bool v) {
    if (bankAccountOpen == v) return;
    bankAccountOpen = v;
    notifyListeners();
  }

  void setExternalBankLinked(bool v) {
    if (externalBankLinked == v) return;
    externalBankLinked = v;
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
    if (isSolo) {
      if (n.isEmpty) return 'You · 100 shares · 100% PSC';
      return '$n · 100 shares · 100% PSC';
    }
    final pcts = sharePercents.join(' / ');
    return '$n + ${coDirectors.length} co-director${coDirectors.length == 1 ? '' : 's'} · '
        'shares $pcts%';
  }
}

/// Invited co-director.
class CoDirector {
  final String name;
  final String email;
  /// Verification status — until they finish their own ID flow this stays
  /// "pending". Mocked in the prototype; in production a webhook from
  /// Stripe Identity flips it to "verified".
  final String status;

  const CoDirector({
    required this.name,
    required this.email,
    this.status = 'pending',
  });
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
