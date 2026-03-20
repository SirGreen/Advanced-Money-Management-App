/// Privacy Mode Service
/// Provides utilities for masking and displaying sensitive financial information
class PrivacyModeService {
  static const String maskSymbol = '•••';
  static const String maskIcon = '🔒';

  /// Mask an amount value
  /// Returns a masked string or the formatted amount based on privacy mode
  static String maskAmount(double? amount, {bool hideAmount = false}) {
    if (amount == null) {
      return hideAmount ? maskSymbol : '0';
    }

    if (hideAmount) {
      return maskSymbol;
    }

    return amount.toStringAsFixed(2);
  }

  /// Mask a currency amount with symbol
  static String maskCurrencyAmount(
    double? amount, {
    required String currency,
    bool hideAmount = false,
  }) {
    if (amount == null) {
      return hideAmount ? '$currency $maskSymbol' : '$currency 0';
    }

    if (hideAmount) {
      return '$currency $maskSymbol';
    }

    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Get blur effect status
  /// When privacy mode is on, UI elements can use blur effect
  static bool shouldBlur(bool privacyModeEnabled) => privacyModeEnabled;

  /// Get optional mask icon display
  /// Returns icon string when privacy mode is enabled
  static String getPrivacyIndicator(bool privacyModeEnabled) {
    return privacyModeEnabled ? maskIcon : '';
  }

  /// Create a blurred text representation
  static String createBlurredText(String text) {
    return text.replaceAll(RegExp(r'.'), '•');
  }

  /// Mask transaction details
  static Map<String, dynamic> maskTransactionDetails(
    Map<String, dynamic> details, {
    required bool hideAmount,
    required bool hideNames,
  }) {
    final masked = {...details};

    if (hideAmount && masked.containsKey('amount')) {
      masked['amount'] = maskSymbol;
    }

    if (hideNames) {
      if (masked.containsKey('articleName')) {
        masked['articleName'] = createBlurredText(
          masked['articleName'] as String,
        );
      }
      if (masked.containsKey('name')) {
        masked['name'] = createBlurredText(masked['name'] as String);
      }
    }

    return masked;
  }
}
