/// Masks ("blurs") content that must not be shared in chat messages:
///
///  * **Phone numbers** — any 10–15 digit run (with optional `+ - ( ) .` or
///    space separators) is replaced entirely with `*`, so contact details
///    cannot be exchanged through the platform.
///  * **Abusive words** — a lexicon of common English and Roman Urdu/Hindi
///    insults (beghairat, kutta, pagal, kamina, …). Only the first letter is
///    kept (`kutta` → `k****`) so readers can tell something was censored.
///
/// Used by both chat surfaces (student↔tutor chat and the AI assistant chat)
/// at every point a message is stored or a reply is returned, so the masking
/// cannot be bypassed by a modified client.
class ContentModerationService {
  /// Candidate phone-number spans: starts and ends with a digit, allowing
  /// separator characters in between. The digit count is checked in code so
  /// prices ("1500") and years stay untouched.
  static final RegExp _phoneCandidate = RegExp(r'\+?\d[\d\s\-().]*\d');

  static const int _minPhoneDigits = 10;
  static const int _maxPhoneDigits = 15;

  /// Common abusive words — English plus Roman Urdu/Hindi with frequent
  /// spelling variants. Matched case-insensitively on word boundaries.
  static const List<String> _abusiveWords = [
    // English
    'fuck', 'fucking', 'fucker', 'motherfucker', 'shit', 'bullshit',
    'bitch', 'bastard', 'asshole', 'arsehole', 'dick', 'dickhead',
    'pussy', 'cunt', 'slut', 'whore', 'wanker', 'prick', 'douchebag',
    'moron', 'idiot', 'stupid', 'dumbass', 'jackass', 'retard',
    // Roman Urdu / Hindi
    'beghairat', 'begairat', 'behaya',
    'bewakoof', 'bewaqoof', 'bevakoof', 'bewkoof',
    'kutta', 'kutte', 'kutti', 'kuttay',
    'kamina', 'kameena', 'kamini', 'kameeni', 'kaminey', 'kameene',
    'harami', 'haraami', 'haramkhor',
    'haramzada', 'haramzaada', 'haramzadi', 'haramzaadi',
    'pagal', 'paagal', 'pagli', 'pagal',
    'gadha', 'gadhe', 'gadhi', 'gadhay',
    'ullu', 'ulloo',
    'chutiya', 'chutiye', 'chutia',
    'madarchod', 'maderchod', 'madarchodh',
    'behenchod', 'bhenchod', 'behanchod',
    'bhosdike', 'bhosdi', 'bhosdika',
    'gandu', 'gaandu', 'ganda', 'gandi', 'gande',
    'randi', 'raand',
    'saala', 'saale', 'saali', 'sala',
    'khota', 'khotay', 'khoti',
    'jahil', 'jaahil',
    'badtameez', 'battameez', 'badtamiz',
    'besharam', 'beshram', 'basharam',
    'ghatiya', 'ghatia',
    'nalayak', 'nalaik', 'nalayaq',
    'nikamma', 'nikammi', 'nikamme',
    'suar', 'suwar', 'soowar',
    'khabees', 'khabis',
    'zaleel', 'zalil',
    'lanat', 'laanat',
    'bakwas', 'bakwaas',
    'dhakkan',
  ];

  static final RegExp _abusePattern = RegExp(
    r'\b(?:' + _abusiveWords.join('|') + r')\b',
    caseSensitive: false,
  );

  /// Returns [text] with phone numbers and abusive words masked. Clean text
  /// is returned unchanged.
  String sanitize(String text) {
    var out = text.replaceAllMapped(_phoneCandidate, (m) {
      final span = m.group(0)!;
      final digitCount = span.replaceAll(RegExp(r'\D'), '').length;
      if (digitCount < _minPhoneDigits || digitCount > _maxPhoneDigits) {
        return span;
      }
      return '*' * span.length;
    });

    out = out.replaceAllMapped(_abusePattern, (m) {
      final word = m.group(0)!;
      return word[0] + '*' * (word.length - 1);
    });

    return out;
  }

  /// True if [sanitize] would change [text] — i.e. it contains a phone
  /// number or abusive language.
  bool containsViolation(String text) => sanitize(text) != text;
}
