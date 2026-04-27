import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of starting a Stripe Identity verification session.
/// `clientSecret` is what the client SDK uses to launch the verification
/// sheet; `url` is a fallback hosted-verification link for environments
/// without the native SDK (e.g. dev WebView preview).
class IdentitySession {
  final String id;
  final String clientSecret;
  final String url;
  const IdentitySession({
    required this.id,
    required this.clientSecret,
    required this.url,
  });
}

class IdentityStatus {
  final String status; // requires_input | processing | verified | canceled
  final String? lastError;
  const IdentityStatus({required this.status, this.lastError});
  bool get isFinal => status == 'verified' || status == 'canceled';
  bool get isVerified => status == 'verified';
}

/// Talks to qpay-backend, which holds the Stripe secret key and creates
/// VerificationSessions on our behalf. The backend exposes:
///
///   POST /verify/start             → { id, client_secret, url }
///   GET  /verify/status?id=<id>    → { status, last_error? }
///
/// When `_baseUrl` is empty the service runs in "demo" mode — `start`
/// returns a fake session and `status` resolves to `verified` after a
/// short delay so the UI is testable end-to-end without keys.
class IdentityService {
  final String? _baseUrl;
  final http.Client _client;

  IdentityService({String? baseUrl, http.Client? client})
      : _baseUrl = (baseUrl != null && baseUrl.isNotEmpty) ? baseUrl : null,
        _client = client ?? http.Client();

  static const String _envBaseUrl =
      String.fromEnvironment('VERIFY_BASE_URL');

  factory IdentityService.fromEnvironment() {
    final url = _envBaseUrl;
    return IdentityService(baseUrl: url.isNotEmpty ? url : null);
  }

  bool get isLive => _baseUrl != null;

  Future<IdentitySession> start({
    required String email,
    required String name,
  }) async {
    if (_baseUrl == null) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return const IdentitySession(
        id: 'demo_session_001',
        clientSecret: 'demo_secret',
        url: 'about:blank',
      );
    }
    final res = await _client.post(
      Uri.parse('$_baseUrl/verify/start'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'name': name}),
    );
    if (res.statusCode != 200) {
      throw IdentityException('Start failed (${res.statusCode}).');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return IdentitySession(
      id: body['id'] as String,
      clientSecret: body['client_secret'] as String,
      url: body['url'] as String? ?? '',
    );
  }

  Future<IdentityStatus> status(String id) async {
    if (_baseUrl == null) {
      // Demo: resolve as verified after a short delay so the UI advances.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return const IdentityStatus(status: 'verified');
    }
    final res = await _client.get(
      Uri.parse('$_baseUrl/verify/status?id=$id'),
      headers: const {'accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw IdentityException('Status check failed (${res.statusCode}).');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return IdentityStatus(
      status: body['status'] as String,
      lastError: body['last_error'] as String?,
    );
  }

  void dispose() => _client.close();
}

class IdentityException implements Exception {
  final String message;
  const IdentityException(this.message);
  @override
  String toString() => message;
}
