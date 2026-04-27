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
  /// Companies House jurisdiction derived from the postcode country.
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
/// Primary path uses Ideal Postcodes (licensed PAF data) when an API key is
/// supplied via `--dart-define=IDEAL_POSTCODES_KEY=...`. If the key is
/// missing we fall back to a free Overpass (OpenStreetMap) lookup, which
/// has partial UK coverage. Empty list = caller should route to manual
/// entry.
class AddressService {
  final String? _idealKey;
  final PostcodeService _postcodeService;
  final http.Client _client;

  AddressService({
    String? idealPostcodesKey,
    PostcodeService? postcodeService,
    http.Client? client,
  })  : _idealKey = _resolveKey(idealPostcodesKey),
        _postcodeService = postcodeService ?? PostcodeService(),
        _client = client ?? http.Client();

  static const String _envKey =
      String.fromEnvironment('IDEAL_POSTCODES_KEY');

  static String? _resolveKey(String? passed) {
    if (passed != null && passed.isNotEmpty) return passed;
    if (_envKey.isNotEmpty) return _envKey;
    return null;
  }

  static const String _idealBase = 'https://api.ideal-postcodes.co.uk/v1';
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const Duration _timeout = Duration(seconds: 12);

  Future<List<UkAddress>> findAddresses(String postcode) async {
    if (_idealKey != null) {
      final fromIdeal = await _findIdeal(postcode);
      if (fromIdeal.isNotEmpty) return fromIdeal;
    }
    return _findOverpass(postcode);
  }

  // ───── Ideal Postcodes (licensed PAF) ─────

  Future<List<UkAddress>> _findIdeal(String postcode) async {
    try {
      final encoded = Uri.encodeComponent(postcode.trim());
      final res = await _client
          .get(Uri.parse('$_idealBase/postcodes/$encoded?api_key=$_idealKey'))
          .timeout(_timeout);
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final code = body['code'];
      if (code != 2000) return const [];
      final results = (body['result'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Map<String, dynamic>>();
      if (results.isEmpty) return const [];

      return results.map(_idealToAddress).whereType<UkAddress>().toList()
        ..sort((a, b) => _addressSortKey(a).compareTo(_addressSortKey(b)));
    } catch (_) {
      return const [];
    }
  }

  static UkAddress? _idealToAddress(Map<String, dynamic> a) {
    final l1 = (a['line_1'] as String? ?? '').trim();
    final l2 = (a['line_2'] as String? ?? '').trim();
    final l3 = (a['line_3'] as String? ?? '').trim();
    final parts = [l1, l2, l3].where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final line1 = parts.join(', ');

    final town = (a['post_town'] as String? ?? '').trim();
    final county = (a['county'] as String? ?? '').trim();
    final locality = town.isNotEmpty
        ? _titleCase(town)
        : (county.isNotEmpty ? county : '');
    final pc = (a['postcode'] as String? ?? '').trim();
    final country = (a['country'] as String? ?? '').trim();
    return UkAddress(
      line1: line1,
      locality: locality,
      postcode: pc,
      jurisdiction: _mapCountry(country),
    );
  }

  static String _titleCase(String s) {
    return s
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))
        .join(' ');
  }

  static ChJurisdiction _mapCountry(String country) {
    switch (country) {
      case 'Scotland':
        return ChJurisdiction.scotland;
      case 'Northern Ireland':
        return ChJurisdiction.northernIreland;
      case 'England':
      case 'Wales':
      default:
        return ChJurisdiction.englandAndWales;
    }
  }

  // ───── Overpass / OSM fallback ─────

  Future<List<UkAddress>> _findOverpass(String postcode) async {
    try {
      final pc = await _postcodeService.lookup(postcode);
      final locality = pc.locality.split(',').first.trim();
      final query =
          '[out:json][timeout:10];nwr["addr:postcode"="${pc.postcode}"];out tags;';
      final res = await _client
          .post(Uri.parse(_overpassUrl), body: query)
          .timeout(_timeout);
      if (res.statusCode != 200) return const [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final elements =
          (body['elements'] as List<dynamic>? ?? const <dynamic>[])
              .cast<Map<String, dynamic>>();
      final out = <UkAddress>[];
      final seen = <String>{};
      for (final el in elements) {
        final tags = (el['tags'] as Map<String, dynamic>? ?? const {});
        final line1 = _composeOsmLine1(tags);
        if (line1 == null || line1.trim().isEmpty) continue;
        if (!seen.add(line1.toLowerCase())) continue;
        out.add(UkAddress(
          line1: line1,
          locality: locality,
          postcode: pc.postcode,
          jurisdiction: pc.jurisdiction,
        ));
      }
      out.sort((a, b) => _addressSortKey(a).compareTo(_addressSortKey(b)));
      return out;
    } catch (_) {
      return const [];
    }
  }

  static String? _composeOsmLine1(Map<String, dynamic> tags) {
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

  // ───── Common ─────

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
