/// A country dial code entry.
class CountryCode {
  final String name;
  final String dial; // e.g. "+92"
  const CountryCode(this.name, this.dial);
}

/// Common world dial codes. Pakistan (+92) is the default.
const List<CountryCode> kCountryCodes = [
  CountryCode('Pakistan', '+92'),
  CountryCode('India', '+91'),
  CountryCode('Bangladesh', '+880'),
  CountryCode('Afghanistan', '+93'),
  CountryCode('United States', '+1'),
  CountryCode('United Kingdom', '+44'),
  CountryCode('United Arab Emirates', '+971'),
  CountryCode('Saudi Arabia', '+966'),
  CountryCode('Qatar', '+974'),
  CountryCode('Kuwait', '+965'),
  CountryCode('Bahrain', '+973'),
  CountryCode('Oman', '+968'),
  CountryCode('Canada', '+1'),
  CountryCode('Australia', '+61'),
  CountryCode('Germany', '+49'),
  CountryCode('France', '+33'),
  CountryCode('Italy', '+39'),
  CountryCode('Spain', '+34'),
  CountryCode('Turkey', '+90'),
  CountryCode('China', '+86'),
  CountryCode('Japan', '+81'),
  CountryCode('Malaysia', '+60'),
  CountryCode('Indonesia', '+62'),
  CountryCode('Singapore', '+65'),
  CountryCode('South Africa', '+27'),
  CountryCode('Egypt', '+20'),
  CountryCode('Nigeria', '+234'),
  CountryCode('Iran', '+98'),
  CountryCode('Sri Lanka', '+94'),
  CountryCode('Nepal', '+977'),
];
