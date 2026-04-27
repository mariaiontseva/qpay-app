import 'dart:convert';

import 'package:http/http.dart' as http;

/// Companies House public-data record for a single company.
class CompanyDetails {
  final String number;
  final String name;
  /// One of: active, dissolved, liquidation, removed, …
  final String status;
  /// ISO date of incorporation, e.g. "2024-07-15".
  final String? incorporated;
  /// Jurisdiction tag from CH (e.g. "england-wales", "scotland").
  final String? jurisdiction;
  final List<String> sicCodes;
  /// Single-line registered-office address.
  final String registeredOffice;

  const CompanyDetails({
    required this.number,
    required this.name,
    required this.status,
    this.incorporated,
    this.jurisdiction,
    this.sicCodes = const [],
    this.registeredOffice = '',
  });

  /// Human-readable incorporation date, e.g. "15 Jul 2024".
  String get incorporatedLabel {
    final raw = incorporated;
    if (raw == null) return '';
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = int.tryParse(parts[1]);
    if (m == null || m < 1 || m > 12) return raw;
    return '${int.parse(parts[2])} ${months[m - 1]} ${parts[0]}';
  }

  String get jurisdictionLabel {
    switch (jurisdiction) {
      case 'england-wales':
        return 'England and Wales';
      case 'scotland':
        return 'Scotland';
      case 'northern-ireland':
        return 'Northern Ireland';
      case null:
      case '':
        return '';
      default:
        return jurisdiction!;
    }
  }
}

class CompanyNotFoundException implements Exception {
  final String message;
  const CompanyNotFoundException([this.message = 'Company not found.']);
  @override
  String toString() => message;
}

/// Result of a name-availability check against the Companies House register.
class NameAvailability {
  /// True when no active company exactly matches the proposed name.
  final bool available;

  /// If [available] is false, the exact name of the blocking company.
  final String? takenBy;

  /// Normalised version of the proposed name as filed (e.g. `Orca Design Ltd`).
  final String filedName;

  const NameAvailability({
    required this.available,
    required this.filedName,
    this.takenBy,
  });
}

/// Thin wrapper around the Companies House Public Data REST API.
///
/// Requires an API key from https://developer.company-information.service.gov.uk.
/// Auth is HTTP Basic with the key as username and an empty password.
///
/// When [_apiKey] is null / empty the service falls back to a mock that
/// pretends every name is available — useful for UI demos without a key.
class CompaniesHouseService {
  final String? _apiKey;
  final http.Client _client;

  CompaniesHouseService(this._apiKey, {http.Client? client})
      : _client = client ?? http.Client();

  static const _base = 'https://api.company-information.service.gov.uk';

  bool get isLive => _apiKey != null && _apiKey.isNotEmpty;

  /// Append the standard "Ltd" suffix we'll file under, then search.
  /// Returns [NameAvailability] describing whether an exact live match exists.
  Future<NameAvailability> checkAvailability(String rawInput) async {
    final base = rawInput.trim();
    final filed = '$base Ltd';

    if (!isLive) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return NameAvailability(available: true, filedName: filed);
    }

    final uri = Uri.parse(
      '$_base/search/companies?q=${Uri.encodeQueryComponent(filed)}&items_per_page=100',
    );
    final auth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';
    final res = await _client.get(
      uri,
      headers: {'Authorization': auth, 'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw CompaniesHouseException(
        'Companies House returned ${res.statusCode}',
      );
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    // An exact, live match on the normalised title blocks us. We ignore
    // dissolved / removed / converted companies since their names are reusable.
    final target = _normalise(filed);
    for (final item in items) {
      final rawTitle = item['title'] as String? ?? '';
      final status = item['company_status'] as String? ?? '';
      if (_normalise(rawTitle) == target && _statusBlocks(status)) {
        return NameAvailability(
          available: false,
          filedName: filed,
          takenBy: rawTitle,
        );
      }
    }
    return NameAvailability(available: true, filedName: filed);
  }

  /// Companies House treats "Limited" and "Ltd" (and a handful of siblings)
  /// as equivalent for the "same as" rule. Strip punctuation, collapse
  /// whitespace, and canonicalise suffixes before comparing.
  String _normalise(String name) {
    var n = name.toLowerCase();
    // Treat various incorporation suffixes as equivalent.
    n = n.replaceAll(RegExp(r'\blimited\b'), 'ltd');
    n = n.replaceAll(RegExp(r'\bcompany\b'), 'co');
    n = n.replaceAll(RegExp(r'\band\b'), '&');
    // Drop punctuation that CH ignores for same-as comparison.
    n = n.replaceAll(RegExp(r'''[.,'’"()\-\u2010-\u2015]'''), ' ');
    // Drop "The " prefix.
    n = n.replaceAll(RegExp(r'^the\s+'), '');
    // Collapse whitespace.
    n = n.replaceAll(RegExp(r'\s+'), ' ').trim();
    return n;
  }

  bool _statusBlocks(String status) {
    // Companies House keeps dissolved names protected for ~20 years and the
    // API doesn't tell us when the name became reusable. Being strict here
    // avoids telling the user "available" for a name that CH would reject.
    // Only explicit "removed" (entity wiped from the register) is safely
    // reusable.
    const reusable = {'removed'};
    return !reusable.contains(status);
  }

  /// Direct profile lookup by company number. Returns the public-data
  /// record. Throws [CompanyNotFoundException] on 404, generic
  /// [CompaniesHouseException] on other non-200 responses.
  Future<CompanyDetails> lookupByNumber(String number) async {
    final n = number.trim();
    if (!isLive) {
      // Mock — no API key. Return a reasonable shape so the UI flow
      // works in dev without burning real lookups.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return CompanyDetails(
        number: n,
        name: 'Demo Company Ltd',
        status: 'active',
        incorporated: '2024-01-01',
        jurisdiction: 'england-wales',
        sicCodes: const ['62012'],
        registeredOffice: 'Demo Address, London, SW1A 1AA',
      );
    }
    final uri = Uri.parse('$_base/company/$n');
    final auth = 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}';
    final res = await _client.get(
      uri,
      headers: {'Authorization': auth, 'Accept': 'application/json'},
    );
    if (res.statusCode == 404) throw const CompanyNotFoundException();
    if (res.statusCode != 200) {
      throw CompaniesHouseException(
        'Companies House returned ${res.statusCode}',
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final addr = (body['registered_office_address'] as Map<String, dynamic>?
            ?? const {})
        .cast<String, dynamic>();
    final addressParts = [
      addr['premises'],
      addr['address_line_1'],
      addr['address_line_2'],
      addr['locality'],
      addr['region'],
      addr['postal_code'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();

    return CompanyDetails(
      number: n,
      name: (body['company_name'] as String? ?? '').trim(),
      status: (body['company_status'] as String? ?? '').trim(),
      incorporated: body['date_of_creation'] as String?,
      jurisdiction: body['jurisdiction'] as String?,
      sicCodes:
          (body['sic_codes'] as List<dynamic>? ?? const <dynamic>[])
              .cast<String>(),
      registeredOffice: addressParts.join(', '),
    );
  }

  void dispose() => _client.close();
}

class CompaniesHouseException implements Exception {
  final String message;
  CompaniesHouseException(this.message);
  @override
  String toString() => 'CompaniesHouseException: $message';
}
