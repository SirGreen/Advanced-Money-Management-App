import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalCurrencyInputFormatter extends TextInputFormatter {
  final String? locale;
  final int maxLength;

  DecimalCurrencyInputFormatter({this.locale, this.maxLength = 15});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Get just the digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (digitsOnly.length > maxLength) {
      return oldValue;
    }

    // 2. Parse as integer (VND usually doesn't need decimals for fast add)
    // If we need decimals later, we can check for decimal separator explicitly.
    // For now, robust "Fast Add" means integer speed.
    int value = int.tryParse(digitsOnly) ?? 0;

    // 3. Re-format using locale
    final formatter = NumberFormat.decimalPattern(locale);
    String newText = formatter.format(value);

    // 4. Calculate cursor position
    // Simple logic: maintain cursor relative to end if adding/removing
    // But standard convenient logic is to put cursor at end for simple inputs
    // Or try to preserve position.

    // Let's try to preserve position logic:
    // Determine how many digits were before cursor in oldValue
    // Find where that digit index is in newText?
    //
    // Simplified robust cursor: Put at end.
    // Users hate "start" cursor, "end" is safer for "Fast Add" (typing numbers sequentially).
    // If they edit middle, it might jump, but acceptable for this fix.

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
