import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class SicCode {
  final String code;
  final String description;
  const SicCode(this.code, this.description);
}

/// Loads UK SIC 2007 codes from `assets/data/sic_codes.json` and exposes a
/// keyword-based search. Index built lazily on first lookup.
class SicService {
  static const String _assetPath = 'assets/data/sic_codes.json';

  List<SicCode>? _all;
  // For each code, lowercase tokens used for matching.
  final Map<String, List<String>> _tokens = {};

  Future<void> _ensureLoaded() async {
    if (_all != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((e) => SicCode(e['c'] as String, e['d'] as String))
        .toList();
    _all = list;
    for (final c in list) {
      _tokens[c.code] = _tokenise(c.description);
    }
  }

  static List<String> _tokenise(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s]", unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toList();
  }

  /// Returns up to [limit] best-matching codes for [query]. Empty query
  /// returns an empty list — callers should hide the result list.
  Future<List<SicCode>> search(String query, {int limit = 8}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    await _ensureLoaded();

    // Direct-code shortcut: if user types a numeric prefix, prefix-match codes.
    if (RegExp(r'^\d+$').hasMatch(q)) {
      return _all!
          .where((c) => c.code.startsWith(q))
          .take(limit)
          .toList();
    }

    final qTokens = _tokenise(q).where((t) => t.length >= 2).toList();
    if (qTokens.isEmpty) return const [];

    final scored = <_Scored>[];
    for (final c in _all!) {
      final desc = c.description.toLowerCase();
      var score = 0;
      var matchedTokens = 0;
      for (final qt in qTokens) {
        // Whole-word match in tokens — strong signal.
        if (_tokens[c.code]!.contains(qt)) {
          score += 4;
          matchedTokens++;
          continue;
        }
        // Substring of any token (catches plurals / partial words).
        final tokenSub =
            _tokens[c.code]!.any((t) => t.startsWith(qt) || t.contains(qt));
        if (tokenSub) {
          score += 2;
          matchedTokens++;
          continue;
        }
        // Plain substring on the whole description.
        if (desc.contains(qt)) {
          score += 1;
          matchedTokens++;
        }
      }
      if (matchedTokens == 0) continue;
      // Bonus when every query token matched.
      if (matchedTokens == qTokens.length) score += 3;
      scored.add(_Scored(c, score));
    }
    scored.sort((a, b) {
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      // Stable on description for deterministic tie-breaks.
      return a.code.description.compareTo(b.code.description);
    });
    return scored.take(limit).map((s) => s.code).toList();
  }

  int get totalCodes => _all?.length ?? 0;
}

class _Scored {
  final SicCode code;
  final int score;
  const _Scored(this.code, this.score);
}
