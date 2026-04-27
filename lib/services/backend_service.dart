import 'dart:convert';

import 'package:http/http.dart' as http;

/// Response from the backend's `/v1/formation/submit-sample` endpoint.
class FormationSubmitResult {
  final String transactionId;
  final String outcome; // accepted | acknowledged | rejected | error
  final String? filedName;
  final int httpStatus;
  final List<FormationError> errors;

  FormationSubmitResult({
    required this.transactionId,
    required this.outcome,
    required this.httpStatus,
    required this.errors,
    this.filedName,
  });

  factory FormationSubmitResult.fromJson(Map<String, dynamic> json) {
    return FormationSubmitResult(
      transactionId: json['transactionId'] as String? ?? '',
      outcome: json['outcome'] as String? ?? 'error',
      httpStatus: (json['httpStatus'] as num?)?.toInt() ?? 0,
      filedName: json['filedName'] as String?,
      errors: ((json['errors'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FormationError.fromJson)
          .toList(),
    );
  }
}

class FormationError {
  final String? code;
  final String text;
  FormationError({required this.text, this.code});
  factory FormationError.fromJson(Map<String, dynamic> json) => FormationError(
        code: json['code'] as String?,
        text: json['text'] as String? ?? '',
      );
}

/// Thin client over the `qpay-backend` HTTP API.
class BackendService {
  final String baseUrl;
  final http.Client _client;

  BackendService(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  /// True if a backend URL was injected at compile time.
  bool get isConfigured => baseUrl.isNotEmpty;

  /// Smoke-test: send just the company name to the sample endpoint, get
  /// back the CH outcome. Used by the Name screen's "Submit to CH" button.
  Future<FormationSubmitResult> submitSample(String companyName) async {
    if (!isConfigured) {
      throw StateError('Backend URL not configured');
    }
    final res = await _client.post(
      Uri.parse('$baseUrl/v1/formation/submit-sample'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'companyName': companyName}),
    );
    if (res.statusCode >= 400) {
      throw HttpException(
        'Backend returned ${res.statusCode}: ${res.body}',
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return FormationSubmitResult.fromJson(body);
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
