import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/country_codes.dart';

/// A phone input with a country-code dropdown (default +92) and a number field
/// limited to digits only, max 10. The bound [controller] receives the full
/// number, e.g. "+923001234567".
class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const PhoneField({
    super.key,
    required this.controller,
    this.hint = 'Phone number',
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late CountryCode _country;
  final _localCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _country = kCountryCodes.first; // Pakistan (+92)
    final raw = widget.controller.text.trim();
    if (raw.startsWith('+')) {
      CountryCode? best;
      for (final c in kCountryCodes) {
        if (raw.startsWith(c.dial) &&
            (best == null || c.dial.length > best.dial.length)) {
          best = c;
        }
      }
      if (best != null) {
        _country = best;
        _localCtrl.text = raw.substring(best.dial.length).replaceAll(RegExp(r'\D'), '');
      } else {
        _localCtrl.text = raw.replaceAll(RegExp(r'\D'), '');
      }
    } else {
      _localCtrl.text = raw.replaceAll(RegExp(r'\D'), '');
    }
    if (_localCtrl.text.length > 10) {
      _localCtrl.text = _localCtrl.text.substring(0, 10);
    }
    _sync();
  }

  @override
  void dispose() {
    _localCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    widget.controller.text =
        _localCtrl.text.isEmpty ? '' : '${_country.dial}${_localCtrl.text}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: DropdownButton<CountryCode>(
              value: _country,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              items: kCountryCodes
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} (${c.dial})'),
                      ))
                  .toList(),
              selectedItemBuilder: (ctx) => kCountryCodes
                  .map((c) => Center(child: Text(c.dial)))
                  .toList(),
              onChanged: (c) {
                if (c == null) return;
                setState(() => _country = c);
                _sync();
              },
            ),
          ),
          Container(width: 1, height: 28, color: theme.dividerColor),
          Expanded(
            child: TextField(
              controller: _localCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) => _sync(),
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
