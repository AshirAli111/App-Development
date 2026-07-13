import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

import '../config/database.dart';
import 'document_validation_service.dart';

/// Extracts OCR text from a tutor's registration documents and stores it on
/// the tutor's own `users` document under the `ocrResults` field, so an admin
/// inspecting the database can verify the tutor without decoding the images.
///
/// Stored shape:
/// ```json
/// {
///   "extractedName":       "<name parsed from the CNIC front, or null>",
///   "extractedCnicNumber": "<#####-#######-# parsed from CNIC front/back, or null>",
///   "documents": {
///     "cnicFront": { "status": "extracted|unreadable|unsupported|ocr_unavailable", "text": "..." },
///     ...
///   },
///   "extractedAt": <date>
/// }
/// ```
///
/// This field is intentionally DB-only: it holds CNIC data and must never be
/// exposed through public API responses (see UserModel.toPublicMap).
class OcrResultsService {
  final _validator = DocumentValidationService();

  DbCollection get _users => Database.instance.collection('users');

  /// Document slots we OCR, in the order they should appear for the admin.
  static const List<String> _docTypes = [
    'cnicFront',
    'cnicBack',
    'teachingCertificate',
    'degree',
  ];

  /// Pakistani CNIC number: 5 digits, 7 digits, 1 digit — with the separators
  /// OCR typically preserves or mangles (hyphen, en dash, space, or nothing).
  static final RegExp _cnicPattern =
      RegExp(r'(?<!\d)\d{5}[-–\s]?\d{7}[-–\s]?\d(?!\d)');

  /// Runs OCR on every supplied document and writes the combined result to
  /// the user's `ocrResults` field. Never throws — this is designed to run
  /// fire-and-forget after the profile-update response; failures are logged.
  Future<void> processAndStore({
    required String userId,
    required Map<String, dynamic> documents,
  }) async {
    try {
      final perDoc = <String, dynamic>{};
      for (final type in _docTypes) {
        final base64 = documents[type];
        if (base64 is! String || base64.isEmpty) continue;
        perDoc[type] = await _ocrOne(base64);
      }
      if (perDoc.isEmpty) return;

      final frontText = _textOf(perDoc['cnicFront']);
      final backText = _textOf(perDoc['cnicBack']);

      final ocrResults = <String, dynamic>{
        'extractedName': parseCnicName(frontText),
        'extractedCnicNumber':
            parseCnicNumber(frontText) ?? parseCnicNumber(backText),
        'documents': perDoc,
        'extractedAt': DateTime.now(),
      };

      await Database.ensureConnected();
      await _users.updateOne(
        where.eq('_id', ObjectId.fromHexString(userId)),
        modify.set('ocrResults', ocrResults),
      );
      print('Stored OCR results for user $userId '
          '(${perDoc.keys.join(', ')})');
    } catch (e) {
      // Fire-and-forget: never let OCR storage break anything upstream.
      print('Failed to store OCR results for user $userId: $e');
    }
  }

  /// OCRs a single base64 document. The stored documents carry no mime type,
  /// so it is sniffed from the magic bytes.
  Future<Map<String, dynamic>> _ocrOne(String base64) async {
    final mimeType = sniffMimeType(base64);
    if (mimeType == null) {
      return {'status': 'unsupported', 'text': null};
    }

    final text =
        await _validator.extractText(fileBase64: base64, mimeType: mimeType);
    if (text == null) {
      return {'status': 'ocr_unavailable', 'text': null};
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return {'status': 'unreadable', 'text': null};
    }
    return {'status': 'extracted', 'text': trimmed};
  }

  String? _textOf(dynamic docResult) =>
      docResult is Map ? docResult['text'] as String? : null;

  /// Detects the image type from the file's magic bytes. Returns null for
  /// PDFs and anything else tesseract can't read directly.
  String? sniffMimeType(String base64) {
    List<int> head;
    try {
      // 16 base64 chars decode to the first 12 bytes — enough for any magic.
      final probe = base64.length >= 16 ? base64.substring(0, 16) : base64;
      head = base64Decode(
        probe.padRight((probe.length + 3) & ~3, '='),
      );
    } catch (_) {
      return null;
    }
    if (head.length < 4) return null;

    if (head[0] == 0x89 && head[1] == 0x50 && head[2] == 0x4E) {
      return 'image/png';
    }
    if (head[0] == 0xFF && head[1] == 0xD8) return 'image/jpeg';
    if (head.length >= 12 &&
        head[0] == 0x52 && // RIFF
        head[1] == 0x49 &&
        head[8] == 0x57 && // WEBP
        head[9] == 0x45) {
      return 'image/webp';
    }
    return null; // %PDF and unknown formats.
  }

  /// Pulls the CNIC number out of OCR text, normalised to #####-#######-#.
  String? parseCnicNumber(String? text) {
    if (text == null) return null;
    final match = _cnicPattern.firstMatch(text);
    if (match == null) return null;
    final digits = match.group(0)!.replaceAll(RegExp(r'\D'), '');
    return '${digits.substring(0, 5)}-'
        '${digits.substring(5, 12)}-'
        '${digits.substring(12)}';
  }

  /// Heuristic for the Pakistani CNIC front layout, where a "Name" caption
  /// line is followed by the holder's name on the next line.
  String? parseCnicName(String? text) {
    if (text == null) return null;
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (var i = 0; i < lines.length - 1; i++) {
      final lower = lines[i].toLowerCase();
      final isNameCaption = lower == 'name' ||
          (lower.contains('name') &&
              !lower.contains('father') &&
              !lower.contains('husband') &&
              !lower.contains('country') &&
              lower.length <= 12);
      if (!isNameCaption) continue;

      // The holder's name: the next line that is mostly letters.
      for (var j = i + 1; j < lines.length; j++) {
        final candidate = lines[j];
        final letters = candidate.replaceAll(RegExp(r'[^A-Za-z ]'), '');
        if (letters.trim().length >= candidate.length * 0.7 &&
            letters.trim().length >= 3) {
          return candidate;
        }
      }
    }
    return null;
  }
}
