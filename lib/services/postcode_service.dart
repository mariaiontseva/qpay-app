import 'dart:convert';

import 'package:http/http.dart' as http;

/// Companies House jurisdiction options that follow from the registered
/// office postcode. Wales is filed as "England and Wales" — same register.
enum ChJurisdiction {
  englandAndWales,
  scotland,
  northernIreland,
}

extension ChJurisdictionLabel on ChJurisdiction {
  String get label {
    switch (this) {
      case ChJurisdiction.englandAndWales:
        return 'England and Wales';
      case ChJurisdiction.scotland:
        return 'Scotland';
      case ChJurisdiction.northernIreland:
        return 'Northern Ireland';
    }
  }
}

class PostcodeResult {
  final String postcode;
  final ChJurisdiction jurisdiction;
  /// Human-readable locality, e.g. "Westminster, London".
  final String locality;

  const PostcodeResult({
    required this.postcode,
    required this.jurisdiction,
    required this.locality,
  });
}

/// Thin wrapper around postcodes.io — free, unauthenticated, UK only.
/// We use it to (a) validate the postcode, (b) derive the CH jurisdiction.
class PostcodeService {
  final http.Client _client;

  PostcodeService({http.Client? client}) : _client = client ?? http.Client();

  static const _base = 'https://api.postcodes.io';

  /// Fast-fail format check used to gate UI before hitting the network.
  /// Mirrors the regex used by postcodes.io itself.
  static bool isPlausible(String input) {
    final s = input.trim().toUpperCase().replaceAll(' ', '');
    if (s.length < 5 || s.length > 7) return false;
    final r = RegExp(
      r'^[A-Z]{1,2}\d[A-Z\d]?\d[A-Z]{2}$',
    );
    return r.hasMatch(s);
  }

  /// Resolves a UK postcode to its jurisdiction and a short locality string.
  /// Throws [PostcodeException] on any non-200 response.
  Future<PostcodeResult> lookup(String input) async {
    final clean = input.trim();
    final encoded = Uri.encodeComponent(clean);
    final res = await _client.get(
      Uri.parse('$_base/postcodes/$encoded'),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode == 404) {
      throw const PostcodeException('Postcode not found.');
    }
    if (res.statusCode != 200) {
      throw PostcodeException(
        'Lookup failed (${res.statusCode}). Check your connection.',
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final result = body['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw const PostcodeException('Postcode not found.');
    }
    final country = (result['country'] as String? ?? '').trim();
    final district = (result['admin_district'] as String? ?? '').trim();
    final region = (result['region'] as String? ?? '').trim();
    final pc = (result['postcode'] as String? ?? clean).trim();

    final jurisdiction = _mapCountry(country);
    final locality = [
      if (district.isNotEmpty) district,
      if (region.isNotEmpty && region != district) region,
    ].join(', ');

    return PostcodeResult(
      postcode: pc,
      jurisdiction: jurisdiction,
      locality: locality.isEmpty ? country : locality,
    );
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

  void dispose() => _client.close();
}

class PostcodeException implements Exception {
  final String message;
  const PostcodeException(this.message);
  @override
  String toString() => message;
}
