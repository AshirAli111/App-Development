import 'dart:convert';

import 'package:test/test.dart';
import 'package:tutorgo_backend/services/ocr_results_service.dart';

/// Unit tests for the OCR-result parsing helpers (TICKET-18).
/// These run standalone — no server or database required:
///   dart test test/ocr_results_test.dart
void main() {
  final service = OcrResultsService();

  group('parseCnicNumber', () {
    test('finds a hyphenated CNIC number', () {
      expect(
        service.parseCnicNumber('Identity Number\n35202-1234567-8\nName'),
        '35202-1234567-8',
      );
    });

    test('normalises a space-separated CNIC number', () {
      expect(
        service.parseCnicNumber('cnic 35202 1234567 8 end'),
        '35202-1234567-8',
      );
    });

    test('returns null when no CNIC number present', () {
      expect(service.parseCnicNumber('no digits here'), isNull);
      expect(service.parseCnicNumber(null), isNull);
    });

    test('does not match longer digit runs', () {
      expect(service.parseCnicNumber('35202123456789012345'), isNull);
    });
  });

  group('parseCnicName', () {
    test('reads the line after the Name caption', () {
      const text = 'ISLAMIC REPUBLIC OF PAKISTAN\n'
          'National Identity Card\n'
          'Name\n'
          'Ashir Ali\n'
          'Father Name\n'
          'Muhammad Aslam\n';
      expect(service.parseCnicName(text), 'Ashir Ali');
    });

    test('skips Father Name captions', () {
      const text = 'Father Name\nMuhammad Aslam\n';
      expect(service.parseCnicName(text), isNull);
    });

    test('skips noise lines that are mostly non-letters', () {
      const text = 'Name\n>>> 35202 <<<\nAshir Ali\n';
      expect(service.parseCnicName(text), 'Ashir Ali');
    });

    test('skips caption lines between Name and the holder name', () {
      const text = 'Full name\n"Father\'s Name: xyz"\nGender\nAshir Ali\n';
      expect(service.parseCnicName(text), 'Ashir Ali');
    });

    test('returns null for null/empty text', () {
      expect(service.parseCnicName(null), isNull);
      expect(service.parseCnicName(''), isNull);
    });
  });

  group('sniffMimeType', () {
    test('detects PNG', () {
      final b64 = base64Encode([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A,
          0x0A, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(service.sniffMimeType(b64), 'image/png');
    });

    test('detects JPEG', () {
      final b64 = base64Encode(
          [0xFF, 0xD8, 0xFF, 0xE0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(service.sniffMimeType(b64), 'image/jpeg');
    });

    test('rejects PDF', () {
      final b64 = base64Encode(utf8.encode('%PDF-1.7 rest of file...'));
      expect(service.sniffMimeType(b64), isNull);
    });

    test('rejects garbage', () {
      expect(service.sniffMimeType('not base64 at all!!!'), isNull);
      expect(service.sniffMimeType(''), isNull);
    });
  });
}
