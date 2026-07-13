/// Country dial codes for the phone-number input used across the app.
///
/// Every phone field pairs one of these dial codes with a 10-digit national
/// number (see `PhoneNumberField`).
library;

class CountryCode {
  final String name;
  final String dialCode; // e.g. "+92"
  final String flag; // emoji flag
  final String iso; // ISO 3166-1 alpha-2

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.iso,
  });

  String get label => '$flag $dialCode';
}

/// Default selection for this (Pakistan-based) app.
const String kDefaultDialCode = '+92';

const List<CountryCode> kCountryCodes = [
  CountryCode(name: 'Pakistan', dialCode: '+92', flag: '🇵🇰', iso: 'PK'),
  CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳', iso: 'IN'),
  CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸', iso: 'US'),
  CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧', iso: 'GB'),
  CountryCode(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪', iso: 'AE'),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦', iso: 'SA'),
  CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦', iso: 'CA'),
  CountryCode(name: 'Australia', dialCode: '+61', flag: '🇦🇺', iso: 'AU'),
  CountryCode(name: 'Bangladesh', dialCode: '+880', flag: '🇧🇩', iso: 'BD'),
  CountryCode(name: 'China', dialCode: '+86', flag: '🇨🇳', iso: 'CN'),
  CountryCode(name: 'Germany', dialCode: '+49', flag: '🇩🇪', iso: 'DE'),
  CountryCode(name: 'France', dialCode: '+33', flag: '🇫🇷', iso: 'FR'),
  CountryCode(name: 'Italy', dialCode: '+39', flag: '🇮🇹', iso: 'IT'),
  CountryCode(name: 'Spain', dialCode: '+34', flag: '🇪🇸', iso: 'ES'),
  CountryCode(name: 'Turkey', dialCode: '+90', flag: '🇹🇷', iso: 'TR'),
  CountryCode(name: 'Malaysia', dialCode: '+60', flag: '🇲🇾', iso: 'MY'),
  CountryCode(name: 'Indonesia', dialCode: '+62', flag: '🇮🇩', iso: 'ID'),
  CountryCode(name: 'Qatar', dialCode: '+974', flag: '🇶🇦', iso: 'QA'),
  CountryCode(name: 'Kuwait', dialCode: '+965', flag: '🇰🇼', iso: 'KW'),
  CountryCode(name: 'Bahrain', dialCode: '+973', flag: '🇧🇭', iso: 'BH'),
  CountryCode(name: 'Oman', dialCode: '+968', flag: '🇴🇲', iso: 'OM'),
  CountryCode(name: 'Afghanistan', dialCode: '+93', flag: '🇦🇫', iso: 'AF'),
  CountryCode(name: 'Iran', dialCode: '+98', flag: '🇮🇷', iso: 'IR'),
  CountryCode(name: 'Sri Lanka', dialCode: '+94', flag: '🇱🇰', iso: 'LK'),
  CountryCode(name: 'Nepal', dialCode: '+977', flag: '🇳🇵', iso: 'NP'),
  CountryCode(name: 'Egypt', dialCode: '+20', flag: '🇪🇬', iso: 'EG'),
  CountryCode(name: 'South Africa', dialCode: '+27', flag: '🇿🇦', iso: 'ZA'),
  CountryCode(name: 'Nigeria', dialCode: '+234', flag: '🇳🇬', iso: 'NG'),
  CountryCode(name: 'Kenya', dialCode: '+254', flag: '🇰🇪', iso: 'KE'),
  CountryCode(name: 'Brazil', dialCode: '+55', flag: '🇧🇷', iso: 'BR'),
  CountryCode(name: 'Russia', dialCode: '+7', flag: '🇷🇺', iso: 'RU'),
  CountryCode(name: 'Japan', dialCode: '+81', flag: '🇯🇵', iso: 'JP'),
  CountryCode(name: 'South Korea', dialCode: '+82', flag: '🇰🇷', iso: 'KR'),
  CountryCode(name: 'Singapore', dialCode: '+65', flag: '🇸🇬', iso: 'SG'),
  CountryCode(name: 'Thailand', dialCode: '+66', flag: '🇹🇭', iso: 'TH'),
  CountryCode(name: 'Netherlands', dialCode: '+31', flag: '🇳🇱', iso: 'NL'),
  CountryCode(name: 'Sweden', dialCode: '+46', flag: '🇸🇪', iso: 'SE'),
  CountryCode(name: 'Switzerland', dialCode: '+41', flag: '🇨🇭', iso: 'CH'),
  CountryCode(name: 'Ireland', dialCode: '+353', flag: '🇮🇪', iso: 'IE'),
  CountryCode(name: 'New Zealand', dialCode: '+64', flag: '🇳🇿', iso: 'NZ'),
  CountryCode(name: 'Belgium', dialCode: '+32', flag: '🇧🇪', iso: 'BE'),
  CountryCode(name: 'Norway', dialCode: '+47', flag: '🇳🇴', iso: 'NO'),
  CountryCode(name: 'Denmark', dialCode: '+45', flag: '🇩🇰', iso: 'DK'),
  CountryCode(name: 'Poland', dialCode: '+48', flag: '🇵🇱', iso: 'PL'),
  CountryCode(name: 'Portugal', dialCode: '+351', flag: '🇵🇹', iso: 'PT'),
  CountryCode(name: 'Greece', dialCode: '+30', flag: '🇬🇷', iso: 'GR'),
  CountryCode(name: 'Mexico', dialCode: '+52', flag: '🇲🇽', iso: 'MX'),
  CountryCode(name: 'Argentina', dialCode: '+54', flag: '🇦🇷', iso: 'AR'),
  CountryCode(name: 'Philippines', dialCode: '+63', flag: '🇵🇭', iso: 'PH'),
  CountryCode(name: 'Vietnam', dialCode: '+84', flag: '🇻🇳', iso: 'VN'),
];
