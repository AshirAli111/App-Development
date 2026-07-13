import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/country_codes.dart';

/// App-wide phone input: a country dial-code dropdown paired with a national
/// number that is always exactly 10 digits.
///
/// Emits the composed value (e.g. `+92 3001234567`) through [onChanged]. Place
/// it inside a [Form] and the built-in 10-digit validation participates in
/// `formKey.currentState!.validate()`.
class PhoneNumberField extends StatefulWidget {
  /// Existing value to seed the field. Accepts a composed value
  /// (`+92 3001234567` / `+923001234567`) or a bare national number.
  final String? initialValue;

  /// Called whenever the dial code or number changes, with the composed value.
  final ValueChanged<String> onChanged;

  final String label;
  final bool enabled;

  /// When false, an empty number is allowed (field is optional).
  final bool isRequired;

  const PhoneNumberField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.label = 'Phone Number',
    this.enabled = true,
    this.isRequired = true,
  });

  /// The national part must be exactly this many digits, everywhere.
  static const int nationalDigits = 10;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late String _dialCode;
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    final parsed = _parse(widget.initialValue);
    _dialCode = parsed.$1;
    _numberController = TextEditingController(text: parsed.$2);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  /// Splits a stored value into (dialCode, nationalDigits).
  (String, String) _parse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return (kDefaultDialCode, '');
    }
    final v = value.trim();
    if (v.startsWith('+')) {
      // Longest matching dial code wins (e.g. +971 before +9).
      final codes = kCountryCodes.map((c) => c.dialCode).toSet().toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      for (final code in codes) {
        if (v.startsWith(code)) {
          final national = v.substring(code.length).replaceAll(RegExp(r'\D'), '');
          return (code, national);
        }
      }
    }
    return (kDefaultDialCode, v.replaceAll(RegExp(r'\D'), ''));
  }

  String get _composed => '$_dialCode ${_numberController.text.trim()}';

  void _emit() => widget.onChanged(_composed);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    // Unique dial codes keyed by "flag dialCode" so +1 US/Canada don't collide.
    final items = kCountryCodes
        .map(
          (c) => DropdownMenuItem<String>(
            value: '${c.iso}|${c.dialCode}',
            child: Text('${c.flag} ${c.dialCode}'),
          ),
        )
        .toList();

    final currentKey = kCountryCodes
        .firstWhere(
          (c) => c.dialCode == _dialCode,
          orElse: () => kCountryCodes.first,
        )
        .let((c) => '${c.iso}|${c.dialCode}');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country dial-code dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          height: 58,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentKey,
              isDense: true,
              onChanged: widget.enabled
                  ? (key) {
                      if (key == null) return;
                      setState(() => _dialCode = key.split('|').last);
                      _emit();
                    }
                  : null,
              items: items,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // National number — always 10 digits
        Expanded(
          child: TextFormField(
            controller: _numberController,
            enabled: widget.enabled,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(PhoneNumberField.nationalDigits),
            ],
            onChanged: (_) => _emit(),
            validator: (value) {
              final digits = (value ?? '').trim();
              if (digits.isEmpty) {
                return widget.isRequired ? 'Phone number is required' : null;
              }
              if (digits.length != PhoneNumberField.nationalDigits) {
                return 'Enter a ${PhoneNumberField.nationalDigits}-digit number';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: widget.label,
              counterText: '',
              hintText: '3001234567',
              border: border,
            ),
          ),
        ),
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) op) => op(this);
}
