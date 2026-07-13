import 'dart:convert';
import 'dart:io';

// import '../config/env.dart'; // Re-enable when the Gemini path is turned on.

/// Verifies that an uploaded registration document actually contains content
/// matching the slot it was uploaded into (e.g. a CNIC front, a degree).
///
/// Strategy (two tiers):
///  1. **OCR (primary, active):** run `tesseract` on the uploaded image, then
///     fuzzy-search the extracted text for keywords specific to the document
///     type. Any single keyword hint — exact substring or a small-edit-distance
///     match to tolerate OCR noise — passes the document. Text extracted but no
///     hint found → rejected as invalid content.
///  2. **Gemini (failover, commented out):** the multimodal `generateContent`
///     path is kept in [_verifyWithGemini] but disabled for now. The intended
///     final chain is Gemini primary → OCR failover; today OCR is the live check.
///
/// Fail-open: if OCR can't run (missing/broken `tesseract`, a PDF it can't read,
/// a crash, or a timeout) the document is accepted so a local dependency issue
/// never blocks a genuine tutor's registration.
class DocumentValidationService {
  /// Human label + the keywords that signal a genuine document of this type.
  /// Keywords were chosen from OCR output of real Pakistani sample documents.
  static const Map<String, _DocSpec> _specs = {
    'cnicFront': _DocSpec(
      label: 'CNIC (front)',
      keywords: [
        'pakistan',
        'identity',
        'national',
        'cnic',
        'islamic republic',
        'country of stay',
        'father',
      ],
    ),
    'cnicBack': _DocSpec(
      label: 'CNIC (back)',
      keywords: [
        'pakistan',
        'address',
        'registrar',
        'surname',
        'identity',
        'cnic',
        'father',
      ],
    ),
    'teachingCertificate': _DocSpec(
      label: 'teaching certificate',
      keywords: [
        'certificate',
        'teacher',
        'teaching',
        'school',
        'diploma',
        'training',
        'educating',
        'students',
        'principal',
        'awarded',
        'recognition',
        'certify',
        'college',
      ],
    ),
    'degree': _DocSpec(
      label: 'degree',
      keywords: [
        'university',
        'degree',
        'bachelor',
        'master',
        'phd',
        'college',
        'certify',
        'certificate',
        'examination',
        'diploma',
        'graduate',
        'faculty',
      ],
    ),
  };

  bool isSupportedType(String type) => _specs.containsKey(type);

  /// Returns `{ valid: bool, reason: String }`.
  Future<Map<String, dynamic>> verify({
    required String type,
    required String fileBase64,
    required String mimeType,
  }) async {
    final spec = _specs[type];
    if (spec == null) {
      throw Exception('Unknown document type: $type');
    }

    // ---- Tier 1: OCR + fuzzy keyword search (active) ---------------------
    return _verifyWithOcr(spec: spec, fileBase64: fileBase64, mimeType: mimeType);

    // ---- Tier 2: Gemini (commented out for now) --------------------------
    // To make Gemini the primary check, call _verifyWithGemini here and fall
    // back to _verifyWithOcr on failure. Left disabled per current design.
    // return _verifyWithGemini(spec: spec, fileBase64: fileBase64, mimeType: mimeType);
  }

  // ------------------------------------------------------------------------
  // OCR path
  // ------------------------------------------------------------------------

  Future<Map<String, dynamic>> _verifyWithOcr({
    required _DocSpec spec,
    required String fileBase64,
    required String mimeType,
  }) async {
    // tesseract reads images, not PDFs — accept PDFs rather than blocking them.
    if (!mimeType.startsWith('image/')) {
      return _failOpen('Could not verify (not an image); accepted.');
    }

    final text = await extractText(fileBase64: fileBase64, mimeType: mimeType);
    if (text == null) {
      // OCR couldn't run (missing/broken tesseract, decode error, timeout).
      return _failOpen('Could not verify automatically; accepted.');
    }

    final lower = text.toLowerCase();
    if (lower.trim().isEmpty) {
      // Text was readable to OCR but empty — no hint → treat as invalid.
      return {
        'valid': false,
        'reason': 'Could not read any text from this ${spec.label}.',
      };
    }

    if (_hasKeywordHint(lower, spec.keywords)) {
      return {'valid': true, 'reason': 'Content matches ${spec.label}.'};
    }
    return {
      'valid': false,
      'reason': 'This document does not look like a ${spec.label}.',
    };
  }

  /// Runs tesseract on a base64-encoded image and returns the raw extracted
  /// text. Returns `null` when OCR could not run at all (non-image input,
  /// missing/broken tesseract, decode error, crash, or timeout) — callers
  /// decide their own fallback policy.
  Future<String?> extractText({
    required String fileBase64,
    required String mimeType,
  }) async {
    if (!mimeType.startsWith('image/')) return null;

    File? tempFile;
    try {
      final bytes = base64Decode(fileBase64);
      final ext = _extensionFor(mimeType);
      tempFile = await File(
        '${Directory.systemTemp.path}/doc_verify_${DateTime.now().microsecondsSinceEpoch}$ext',
      ).writeAsBytes(bytes);

      final result = await Process.run(
        'tesseract',
        [tempFile.path, 'stdout'],
      ).timeout(const Duration(seconds: 20));

      if (result.exitCode != 0) return null;
      return result.stdout as String;
    } catch (_) {
      // ProcessException (not installed), timeout, decode error, etc.
      return null;
    } finally {
      if (tempFile != null) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> _failOpen(String reason) => {
        'valid': true,
        'reason': reason,
      };

  /// True if any keyword appears in [text] as a substring, or (for single-word
  /// keywords) any token in the text is within a small edit distance of it —
  /// tolerating OCR misreads like "certfied" for "certified".
  bool _hasKeywordHint(String text, List<String> keywords) {
    // Substring pass — also covers multi-word keywords ("country of stay").
    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }

    // Fuzzy pass over single-word keywords.
    final tokens = text
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 3)
        .toList();
    for (final kw in keywords) {
      if (kw.contains(' ')) continue; // multi-word handled above
      final tolerance = kw.length <= 5 ? 1 : 2;
      for (final tok in tokens) {
        if ((tok.length - kw.length).abs() > tolerance) continue;
        if (_levenshtein(tok, kw) <= tolerance) return true;
      }
    }
    return false;
  }

  /// Standard Levenshtein edit distance.
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        curr[j + 1] = [
          curr[j] + 1, // insertion
          prev[j + 1] + 1, // deletion
          prev[j] + cost, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }

  String _extensionFor(String mimeType) {
    if (mimeType.contains('png')) return '.png';
    if (mimeType.contains('webp')) return '.webp';
    return '.jpg';
  }

  // ------------------------------------------------------------------------
  // Gemini path — COMMENTED OUT.
  //
  // Kept for when we switch back to the AI check (Gemini primary, OCR failover).
  // Uses `gemini-flash-latest` multimodally: the file is sent as inline_data with
  // a per-type prompt, forcing responseMimeType: application/json so the model
  // returns { "valid": bool, "reason": string }. Re-enable the `../config/env.dart`
  // import above before uncommenting.
  // ------------------------------------------------------------------------
  //
  // static const String _geminiBaseUrl =
  //     'https://generativelanguage.googleapis.com/v1beta/models';
  //
  // Future<Map<String, dynamic>> _verifyWithGemini({
  //   required _DocSpec spec,
  //   required String fileBase64,
  //   required String mimeType,
  // }) async {
  //   if (Env.geminiApiKey.isEmpty) {
  //     throw Exception('Document validation is not configured (missing API key)');
  //   }
  //
  //   final prompt = '''
  // You are verifying a document uploaded by a tutor registering on a Pakistani
  // online tutoring platform. The documents are in English.
  //
  // The uploaded file was submitted as: ${spec.label}.
  //
  // Look at the attached file and decide whether its content genuinely matches the
  // expected document type. Be reasonably lenient about layout and scan quality,
  // but reject files that are clearly a different kind of document, blank, or
  // unrelated content.
  //
  // Respond ONLY with a JSON object of the form:
  // {"valid": true or false, "reason": "<short explanation, max 15 words>"}''';
  //
  //   final payload = jsonEncode({
  //     'contents': [
  //       {
  //         'role': 'user',
  //         'parts': [
  //           {'text': prompt},
  //           {
  //             'inline_data': {'mime_type': mimeType, 'data': fileBase64}
  //           },
  //         ],
  //       }
  //     ],
  //     'generationConfig': {
  //       'temperature': 0.0,
  //       'maxOutputTokens': 100,
  //       'responseMimeType': 'application/json',
  //     },
  //   });
  //
  //   final endpoint =
  //       Uri.parse('$_geminiBaseUrl/${Env.geminiModel}:generateContent');
  //   final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  //   try {
  //     final request = await client.postUrl(endpoint);
  //     request.headers.contentType = ContentType.json;
  //     request.headers.set('x-goog-api-key', Env.geminiApiKey);
  //     request.add(utf8.encode(payload));
  //     final response = await request.close();
  //     final bodyBytes = await response
  //         .fold<List<int>>(<int>[], (b, chunk) => b..addAll(chunk));
  //     final body = utf8.decode(bodyBytes, allowMalformed: true);
  //     if (response.statusCode != 200) {
  //       throw Exception('AI service error: HTTP ${response.statusCode}');
  //     }
  //     final data = jsonDecode(body) as Map<String, dynamic>;
  //     final text = _extractGeminiText(data);
  //     final parsed = _parseVerdict(text ?? '');
  //     if (parsed == null) throw Exception('Unparseable AI response');
  //     final valid = parsed['valid'] == true;
  //     final reason = parsed['reason']?.toString() ??
  //         (valid ? 'Looks valid.' : 'Content does not match.');
  //     return {'valid': valid, 'reason': reason};
  //   } finally {
  //     client.close(force: true);
  //   }
  // }
  //
  // Map<String, dynamic>? _parseVerdict(String text) {
  //   try {
  //     final decoded = jsonDecode(text);
  //     if (decoded is Map<String, dynamic>) return decoded;
  //   } catch (_) {}
  //   final start = text.indexOf('{');
  //   final end = text.lastIndexOf('}');
  //   if (start != -1 && end > start) {
  //     try {
  //       final decoded = jsonDecode(text.substring(start, end + 1));
  //       if (decoded is Map<String, dynamic>) return decoded;
  //     } catch (_) {}
  //   }
  //   return null;
  // }
  //
  // String? _extractGeminiText(Map<String, dynamic> data) {
  //   final candidates = data['candidates'] as List?;
  //   if (candidates == null || candidates.isEmpty) return null;
  //   final parts = (candidates[0] as Map?)?['content']?['parts'] as List?;
  //   if (parts == null || parts.isEmpty) return null;
  //   final buffer = StringBuffer();
  //   for (final p in parts) {
  //     final t = (p as Map?)?['text']?.toString();
  //     if (t != null) buffer.write(t);
  //   }
  //   final text = buffer.toString().trim();
  //   return text.isEmpty ? null : text;
  // }
}

class _DocSpec {
  final String label;
  final List<String> keywords;
  const _DocSpec({required this.label, required this.keywords});
}
