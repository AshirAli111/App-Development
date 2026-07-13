import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Result of an AI document check. [valid] is whether the content matched the
/// slot; [reason] is a short human-readable explanation.
class DocumentValidationResult {
  final bool valid;
  final String reason;
  const DocumentValidationResult({required this.valid, required this.reason});
}

/// Talks to the backend document verifier (`POST /documents/verify`), which
/// proxies to Gemini. This route is public (no token) because it runs during
/// tutor profile setup before the account is created.
class DocumentValidationService {
  final String baseUrl;

  DocumentValidationService({required this.baseUrl});

  static const int _maxBytes = 4 * 1024 * 1024; // 4MB safety cap for the API.

  /// Reads [file], sends it to the backend for the given [type]
  /// (`cnicFront`, `cnicBack`, `teachingCertificate`, `degree`) and returns the
  /// verdict.
  ///
  /// Fail-open: if the network/AI call fails (or times out), returns a valid
  /// result so a service outage never blocks a genuine registration.
  Future<DocumentValidationResult> validate({
    required File file,
    required String type,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxBytes) {
        return const DocumentValidationResult(
          valid: false,
          reason: 'File is too large (max 4MB).',
        );
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/documents/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'type': type,
              'fileBase64': base64Encode(bytes),
              'mimeType': _mimeTypeFor(file.path),
            }),
          )
          .timeout(const Duration(seconds: 35));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return DocumentValidationResult(
          valid: data['valid'] == true,
          reason: data['reason']?.toString() ?? '',
        );
      }
      // Non-200 (e.g. 502 AI outage) → fail-open.
      return const DocumentValidationResult(
        valid: true,
        reason: 'Could not verify automatically; accepted.',
      );
    } catch (_) {
      // Network error / timeout → fail-open.
      return const DocumentValidationResult(
        valid: true,
        reason: 'Could not verify automatically; accepted.',
      );
    }
  }

  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}
