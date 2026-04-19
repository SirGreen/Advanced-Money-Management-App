import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalCurrencyInputFormatter extends TextInputFormatter {
  final String? locale;
  final String currencyCode;
  final int maxLength;

  DecimalCurrencyInputFormatter({
    this.locale,
    this.currencyCode = 'VND',
    this.maxLength = 15,
  });

  static double parse(String text, {String currencyCode = 'VND'}) {
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return 0;

    double value = double.tryParse(digitsOnly) ?? 0;
    if (currencyCode == 'JPY' || currencyCode == 'VND') {
      return value;
    } else {
      return value / 100;
    }
  }

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

    // 2. Parse as number
    int rawValue = int.tryParse(digitsOnly) ?? 0;
    String newText;

    // 3. Re-format using locale
    if (currencyCode == 'JPY' || currencyCode == 'VND') {
      // For zero-decimal currencies, treat as a standard integer with group separators
      newText = NumberFormat.decimalPattern(locale).format(rawValue);
    } else {
      // For decimal currencies (like USD, EUR), implement "Fast Add" decimal logic:
      // typing "123" results in "1.23"
      double decimalValue = rawValue / 100;
      newText = NumberFormat.currency(
        locale: locale,
        symbol: '',
        decimalDigits: 2,
      ).format(decimalValue).trim();
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
