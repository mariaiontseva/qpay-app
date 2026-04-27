import 'dart:convert';

import 'package:http/http.dart' as http;

import 'postcode_service.dart';

/// One pickable address for a given postcode.
class UkAddress {
  /// Building number / name + thoroughfare, e.g. "1 Buckingham Gate".
  final String line1;
  /// Locality, e.g. "London".
  final String locality;
  final String postcode;
  /// Companies House jurisdiction derived from the postcode.
  final ChJurisdiction jurisdiction;

  const UkAddress({
    required this.line1,
    required this.locality,
    required this.postcode,
    required this.jurisdiction,
  });
}

/// Resolves a UK postcode to a list of pickable addresses.
///
/// Uses postcodes.io to validate and derive jurisdiction, then queries the
/// public Overpass API (OpenStreetMap) for real buildings tagged with
/// `addr:postcode = <pc>`. Coverage is partial — central UK has good data,
/// rural areas can return zero — so callers must handle the empty-list
/// case (UI routes those to manual entry).
class AddressService {
  final PostcodeService _postcodeService;
  final http.Client _client;

  AddressService({PostcodeService? postcodeService, http.Client? client})
      : _postcodeService = postcodeService ?? PostcodeService(),
        _client = client ?? http.Client();

  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const Duration _overpassTimeout = Duration(seconds: 12);

  Future<List<UkAddress>> findAddresses(String postcode) async {
    final pc = await _postcodeService.lookup(postcode);
    final locality = pc.locality.split(',').first.trim();

    final query =
        '[out:json][timeout:10];nwr["addr:postcode"="${pc.postcode}"];out tags;';
    try {
      final res = await _client
          .post(
            Uri.parse(_overpassUrl),
            body: query,
          )
          .timeout(_overpassTimeout);
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final elements =
          (body['elements'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();

      final out = <UkAddress>[];
      final seen = <String>{};
      for (final el in elements) {
        final tags = (el['tags'] as Map<String, dynamic>? ?? const {});
        final line1 = _composeLine1(tags);
        if (line1 == null || line1.trim().isEmpty) continue;
        if (!seen.add(line1.toLowerCase())) continue;
        out.add(UkAddress(
          line1: line1,
          locality: locality,
          postcode: pc.postcode,
          jurisdiction: pc.jurisdiction,
        ));
      }
      // Sort: numeric house numbers first (ascending), then alpha.
      out.sort((a, b) => _addressSortKey(a).compareTo(_addressSortKey(b)));
      return out;
    } catch (_) {
      // Network / parse failure → empty so UI falls through to manual entry.
      return const [];
    }
  }

  static String? _composeLine1(Map<String, dynamic> tags) {
    final num_ = (tags['addr:housenumber'] as String?)?.trim();
    final street = (tags['addr:street'] as String?)?.trim();
    final houseName = (tags['addr:housename'] as String?)?.trim();
    final name = (tags['name'] as String?)?.trim();
    if (num_ != null && num_.isNotEmpty && street != null && street.isNotEmpty) {
      return '$num_ $street';
    }
    if (houseName != null && houseName.isNotEmpty) {
      if (street != null && street.isNotEmpty) return '$houseName, $street';
      return houseName;
    }
    if (name != null && name.isNotEmpty) return name;
    if (street != null && street.isNotEmpty) return street;
    return null;
  }

  static String _addressSortKey(UkAddress a) {
    final m = RegExp(r'^(\d+)').firstMatch(a.line1);
    if (m != null) {
      final n = int.tryParse(m.group(1)!) ?? 999999;
      return '${n.toString().padLeft(7, "0")} ${a.line1}';
    }
    return 'z ${a.line1}';
  }

  void dispose() {
    _postcodeService.dispose();
    _client.close();
  }
}
