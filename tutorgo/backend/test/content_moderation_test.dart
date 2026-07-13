import 'package:test/test.dart';
import 'package:tutorgo_backend/services/content_moderation_service.dart';

/// Unit tests for chat moderation (TICKET-19). Standalone — no server or
/// database required:
///   dart test test/content_moderation_test.dart
void main() {
  final moderation = ContentModerationService();

  group('phone number masking', () {
    test('masks a bare Pakistani mobile number', () {
      expect(moderation.sanitize('call me at 03001234567 tonight'),
          'call me at *********** tonight');
    });

    test('masks +92 format with spaces', () {
      final out = moderation.sanitize('my number is +92 300 1234567');
      expect(out.contains('+92'), isFalse);
      expect(out.contains('1234567'), isFalse);
      expect(out, startsWith('my number is '));
    });

    test('masks dashed format', () {
      expect(moderation.sanitize('0300-1234567'), '************');
    });

    test('leaves prices and short numbers alone', () {
      expect(moderation.sanitize('the fee is 1500 PKR for 2 hours'),
          'the fee is 1500 PKR for 2 hours');
      expect(moderation.sanitize('see you at 10:30'), 'see you at 10:30');
    });
  });

  group('abusive word masking', () {
    test('masks Roman Urdu insults keeping the first letter', () {
      expect(moderation.sanitize('tum kutta ho'), 'tum k**** ho');
      expect(moderation.sanitize('beghairat insaan'), 'b******** insaan');
      expect(moderation.sanitize('pagal ho kya'), 'p**** ho kya');
    });

    test('masks English profanity', () {
      expect(moderation.sanitize('you are an idiot'), 'you are an i****');
      expect(moderation.sanitize('this is bullshit'), 'this is b*******');
    });

    test('is case-insensitive', () {
      expect(moderation.sanitize('KUTTA'), 'K****');
      expect(moderation.sanitize('Beghairat'), 'B********');
    });

    test('does not mask inside longer clean words', () {
      // "sala" must not fire inside "salaam" or "salad".
      expect(moderation.sanitize('salaam bhai'), 'salaam bhai');
      expect(moderation.sanitize('I ate a salad'), 'I ate a salad');
    });

    test('masks multiple violations in one message', () {
      final out =
          moderation.sanitize('kutta kamina, call 03001234567 you idiot');
      expect(out, 'k**** k*****, call *********** you i****');
    });
  });

  group('clean text', () {
    test('passes through unchanged', () {
      const text = 'Can we move the maths class to 5pm on Tuesday?';
      expect(moderation.sanitize(text), text);
      expect(moderation.containsViolation(text), isFalse);
    });

    test('containsViolation flags dirty text', () {
      expect(moderation.containsViolation('kutta'), isTrue);
      expect(moderation.containsViolation('03001234567'), isTrue);
    });
  });
}
