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
/// Real Royal Mail PAF data sits behind paid APIs (getaddress.io,
/// ideal-postcodes, etc.). Until a key is wired up via
/// `--dart-define=GETADDRESS_API_KEY=...` we fall back to a deterministic
/// mock that derives plausible buildings from the postcode locality, so
/// the sub-flow is testable end-to-end.
class AddressService {
  final PostcodeService _postcodeService;

  AddressService({PostcodeService? postcodeService})
      : _postcodeService = postcodeService ?? PostcodeService();

  Future<List<UkAddress>> findAddresses(String postcode) async {
    final pc = await _postcodeService.lookup(postcode);
    return _mock(pc);
  }

  List<UkAddress> _mock(PostcodeResult pc) {
    final locality = pc.locality.split(',').first.trim();
    // A small pool keyed by the postcode area; if nothing matches, generate
    // numbered "<Locality> Road" addresses so every UK postcode resolves to
    // at least 5 entries.
    final area = pc.postcode.split(' ').first;
    final pool = _curated[area] ?? _generic(locality);
    return pool
        .map((line1) => UkAddress(
              line1: line1,
              locality: locality,
              postcode: pc.postcode,
              jurisdiction: pc.jurisdiction,
            ))
        .toList();
  }

  static List<String> _generic(String locality) => [
        '1 $locality Road',
        '2 $locality Road',
        '3 $locality Road',
        '12 High Street',
        '14 High Street',
        '1 Park Lane',
      ];

  // A few well-known postcode areas seeded with real-feeling buildings so the
  // demo looks credible. Add more as needed; falls back to _generic otherwise.
  static const Map<String, List<String>> _curated = {
    'SW1A': [
      'Buckingham Palace',
      '1 Buckingham Gate',
      '2 Buckingham Gate',
      '3 Buckingham Gate',
      'Stable Yard House',
      '10 Downing Street',
    ],
    'EC1A': [
      '1 St Martin\'s Le Grand',
      '2 St Martin\'s Le Grand',
      '5 King Edward Street',
      '10 Aldersgate Street',
      '15 Newgate Street',
    ],
    'EC2': [
      '1 Liverpool Street',
      '8 Bishopsgate',
      '22 Bishopsgate',
      '1 Old Broad Street',
      '120 Moorgate',
    ],
    'EH1': [
      '1 Princes Street',
      '3 North Bridge',
      '15 George Street',
      '20 Hanover Street',
      '5 Royal Mile',
    ],
    'BT1': [
      '1 Royal Avenue',
      '9 Donegall Square',
      '20 Wellington Place',
      '5 Belfast Tower',
      '14 Howard Street',
    ],
    'CF10': [
      '1 Capital Quarter',
      '5 Callaghan Square',
      '12 Westgate Street',
      '20 Park Place',
      '8 Greyfriars Road',
    ],
  };

  void dispose() {
    _postcodeService.dispose();
  }
}
